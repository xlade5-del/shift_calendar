import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/event_model.dart';
import '../models/sync_queue_model.dart';

/// Database helper for local SQLite storage
/// Manages event caching and sync queue for offline mode
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shift_calendar.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    // Events table for offline caching
    await db.execute('''
      CREATE TABLE events (
        eventId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        notes TEXT,
        color TEXT NOT NULL,
        source TEXT NOT NULL,
        icalUid TEXT,
        version INTEGER NOT NULL DEFAULT 1,
        workplaceId TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Sync queue table for offline changes
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL CHECK(operation IN ('create', 'update', 'delete')),
        event_data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL CHECK(status IN ('pending', 'syncing', 'failed')),
        error_message TEXT
      )
    ''');

    // Indexes for performance
    await db.execute('''
      CREATE INDEX idx_events_userId ON events(userId)
    ''');

    await db.execute('''
      CREATE INDEX idx_events_startTime ON events(startTime)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_queue_status ON sync_queue(status)
    ''');
  }

  /// Upgrade database schema
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
    if (oldVersion < 2) {
      // Example: Add new column in version 2
      // await db.execute('ALTER TABLE events ADD COLUMN newField TEXT');
    }
  }

  // ==================== EVENT CACHE OPERATIONS ====================

  /// Cache event locally
  Future<void> cacheEvent(EventModel event) async {
    final db = await database;
    await db.insert(
      'events',
      _eventToMap(event),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Cache multiple events
  Future<void> cacheEvents(List<EventModel> events) async {
    final db = await database;
    final batch = db.batch();
    for (final event in events) {
      batch.insert(
        'events',
        _eventToMap(event),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Get cached event by ID
  Future<EventModel?> getCachedEvent(String eventId) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'eventId = ?',
      whereArgs: [eventId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _eventFromMap(results.first);
  }

  /// Get all cached events for a user
  Future<List<EventModel>> getCachedEventsForUser(String userId) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'startTime ASC',
    );

    return results.map((map) => _eventFromMap(map)).toList();
  }

  /// Get cached events for a date range
  Future<List<EventModel>> getCachedEventsForRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'userId = ? AND startTime >= ? AND startTime <= ?',
      whereArgs: [
        userId,
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'startTime ASC',
    );

    return results.map((map) => _eventFromMap(map)).toList();
  }

  /// Update cached event
  Future<void> updateCachedEvent(EventModel event) async {
    final db = await database;
    await db.update(
      'events',
      _eventToMap(event),
      where: 'eventId = ?',
      whereArgs: [event.eventId],
    );
  }

  /// Delete cached event
  Future<void> deleteCachedEvent(String eventId) async {
    final db = await database;
    await db.delete(
      'events',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  /// Clear all cached events
  Future<void> clearEventCache() async {
    final db = await database;
    await db.delete('events');
  }

  /// Get count of cached events
  Future<int> getCachedEventCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM events');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== SYNC QUEUE OPERATIONS ====================

  /// Add item to sync queue
  Future<int> addToSyncQueue(SyncQueueModel item) async {
    final db = await database;
    return await db.insert('sync_queue', item.toMap());
  }

  /// Get all pending sync queue items
  Future<List<SyncQueueModel>> getPendingSyncItems() async {
    final db = await database;
    final results = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [SyncQueueModel.statusToString(SyncStatus.pending)],
      orderBy: 'timestamp ASC',
    );

    return results.map((map) => SyncQueueModel.fromMap(map)).toList();
  }

  /// Get all sync queue items
  Future<List<SyncQueueModel>> getAllSyncItems() async {
    final db = await database;
    final results = await db.query(
      'sync_queue',
      orderBy: 'timestamp ASC',
    );

    return results.map((map) => SyncQueueModel.fromMap(map)).toList();
  }

  /// Update sync queue item
  Future<void> updateSyncItem(SyncQueueModel item) async {
    final db = await database;
    await db.update(
      'sync_queue',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Delete sync queue item
  Future<void> deleteSyncItem(int id) async {
    final db = await database;
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear completed sync items
  Future<void> clearCompletedSyncItems() async {
    final db = await database;
    // Only keep failed items for retry
    await db.delete(
      'sync_queue',
      where: 'status != ?',
      whereArgs: [SyncQueueModel.statusToString(SyncStatus.failed)],
    );
  }

  /// Clear all sync queue items
  Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }

  /// Get count of pending sync items
  Future<int> getPendingSyncCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM sync_queue WHERE status = ?',
      [SyncQueueModel.statusToString(SyncStatus.pending)],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get failed sync items
  Future<List<SyncQueueModel>> getFailedSyncItems() async {
    final db = await database;
    final results = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [SyncQueueModel.statusToString(SyncStatus.failed)],
      orderBy: 'timestamp ASC',
    );

    return results.map((map) => SyncQueueModel.fromMap(map)).toList();
  }

  /// Retry failed sync items
  Future<void> retryFailedSyncItems() async {
    final db = await database;
    await db.update(
      'sync_queue',
      {
        'status': SyncQueueModel.statusToString(SyncStatus.pending),
        'retry_count': 0,
        'error_message': null,
      },
      where: 'status = ?',
      whereArgs: [SyncQueueModel.statusToString(SyncStatus.failed)],
    );
  }

  // ==================== HELPER METHODS ====================

  /// Convert EventModel to Map for SQLite
  Map<String, dynamic> _eventToMap(EventModel event) {
    return {
      'eventId': event.eventId,
      'userId': event.userId,
      'title': event.title,
      'startTime': event.startTime.millisecondsSinceEpoch,
      'endTime': event.endTime.millisecondsSinceEpoch,
      'notes': event.notes,
      'color': event.color,
      'source': event.source.name,
      'icalUid': event.icalUid,
      'version': event.version,
      'workplaceId': event.workplaceId,
      'createdAt': event.createdAt.millisecondsSinceEpoch,
      'updatedAt': event.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Convert Map to EventModel
  EventModel _eventFromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map['eventId'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      notes: map['notes'] as String?,
      color: map['color'] as String,
      source: EventSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => EventSource.manual,
      ),
      icalUid: map['icalUid'] as String?,
      version: map['version'] as int? ?? 1,
      workplaceId: map['workplaceId'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database (for testing/debugging)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shift_calendar.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final eventCount = await getCachedEventCount();
    final pendingSyncCount = await getPendingSyncCount();
    final failedSyncCount = (await getFailedSyncItems()).length;

    return {
      'cachedEvents': eventCount,
      'pendingSync': pendingSyncCount,
      'failedSync': failedSyncCount,
    };
  }
}
