import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/shift_template_model.dart';
import '../models/workplace_model.dart';

/// Service for managing Firestore database operations
/// Handles user data, partner linking, and partner code generation
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static const String usersCollection = 'users';
  static const String partnerCodesCollection = 'partnerCodes';
  static const String eventsCollection = 'events';
  static const String shiftTemplatesCollection = 'shiftTemplates';
  static const String workplacesCollection = 'workplaces';

  /// Get user data by user ID
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();

      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!, uid);
    } catch (e) {
      throw 'Error fetching user data: $e';
    }
  }

  /// Update user data
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(usersCollection).doc(uid).update(data);
    } catch (e) {
      throw 'Error updating user: $e';
    }
  }

  /// Generate a unique 6-digit partner code
  /// Code expires in 24 hours and can only be used once
  Future<String> generatePartnerCode(String userId) async {
    try {
      // Generate a random 6-digit code
      final random = Random.secure();
      String code;
      bool isUnique = false;
      int attempts = 0;
      const maxAttempts = 10;

      // Keep trying until we get a unique code
      do {
        code = (random.nextInt(900000) + 100000).toString(); // 100000-999999

        // Check if code already exists and is not expired
        final existingCode = await _firestore
            .collection(partnerCodesCollection)
            .doc(code)
            .get();

        if (!existingCode.exists) {
          isUnique = true;
        } else {
          // Check if existing code is expired
          final data = existingCode.data()!;
          final expiresAt = (data['expiresAt'] as Timestamp).toDate();
          if (DateTime.now().isAfter(expiresAt)) {
            isUnique = true; // Can reuse expired codes
          }
        }

        attempts++;
        if (attempts >= maxAttempts && !isUnique) {
          throw 'Failed to generate unique partner code. Please try again.';
        }
      } while (!isUnique);

      // Store the partner code in Firestore
      await _firestore.collection(partnerCodesCollection).doc(code).set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
        'used': false,
      });

      return code;
    } catch (e) {
      throw 'Error generating partner code: $e';
    }
  }

  /// Validate and use a partner code to link users
  /// Returns the user ID of the code owner
  Future<String> validateAndUsePartnerCode(String code, String currentUserId) async {
    try {
      // Get the partner code document
      final codeDoc = await _firestore
          .collection(partnerCodesCollection)
          .doc(code)
          .get();

      if (!codeDoc.exists) {
        throw 'Invalid partner code. Please check and try again.';
      }

      final codeData = codeDoc.data()!;

      // Check if code has been used
      if (codeData['used'] == true) {
        throw 'This partner code has already been used.';
      }

      // Check if code is expired
      final expiresAt = (codeData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw 'This partner code has expired. Please request a new code.';
      }

      final partnerUserId = codeData['userId'] as String;

      // Prevent user from using their own code
      if (partnerUserId == currentUserId) {
        throw 'You cannot use your own partner code.';
      }

      // Check if current user already has a partner
      final currentUser = await getUserData(currentUserId);
      if (currentUser?.partnerId != null) {
        throw 'You are already linked with a partner. Unlink first to add a new partner.';
      }

      // Check if partner already has a different partner
      final partnerUser = await getUserData(partnerUserId);
      if (partnerUser?.partnerId != null && partnerUser!.partnerId != currentUserId) {
        throw 'This user is already linked with another partner.';
      }

      // Use a batch write to ensure atomicity
      final batch = _firestore.batch();

      // Update both users to link them as partners
      batch.update(
        _firestore.collection(usersCollection).doc(currentUserId),
        {
          'partnerId': partnerUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      batch.update(
        _firestore.collection(usersCollection).doc(partnerUserId),
        {
          'partnerId': currentUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Mark the code as used
      batch.update(
        _firestore.collection(partnerCodesCollection).doc(code),
        {
          'used': true,
          'usedAt': FieldValue.serverTimestamp(),
          'usedBy': currentUserId,
        },
      );

      // Commit the batch
      await batch.commit();

      return partnerUserId;
    } catch (e) {
      if (e is String) rethrow;
      throw 'Error validating partner code: $e';
    }
  }

  /// Unlink current user from their partner
  Future<void> unlinkPartner(String userId) async {
    try {
      // Get current user data
      final currentUser = await getUserData(userId);
      if (currentUser?.partnerId == null) {
        throw 'You are not currently linked with a partner.';
      }

      final partnerId = currentUser!.partnerId!;

      // Use a batch write to ensure atomicity
      final batch = _firestore.batch();

      // Remove partner link from both users
      batch.update(
        _firestore.collection(usersCollection).doc(userId),
        {
          'partnerId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      batch.update(
        _firestore.collection(usersCollection).doc(partnerId),
        {
          'partnerId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Commit the batch
      await batch.commit();
    } catch (e) {
      if (e is String) rethrow;
      throw 'Error unlinking partner: $e';
    }
  }

  /// Get partner data for current user
  Future<UserModel?> getPartnerData(String userId) async {
    try {
      final currentUser = await getUserData(userId);

      if (currentUser?.partnerId == null) {
        return null;
      }

      return await getUserData(currentUser!.partnerId!);
    } catch (e) {
      throw 'Error fetching partner data: $e';
    }
  }

  /// Stream of user data (real-time updates)
  Stream<UserModel?> userDataStream(String uid) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    });
  }

  /// Stream of partner data (real-time updates)
  Stream<UserModel?> partnerDataStream(String userId) {
    return userDataStream(userId).asyncMap((user) async {
      if (user?.partnerId == null) return null;
      return await getUserData(user!.partnerId!);
    });
  }

  /// Check if a user has a partner
  Future<bool> hasPartner(String userId) async {
    try {
      final user = await getUserData(userId);
      return user?.partnerId != null;
    } catch (e) {
      return false;
    }
  }

  /// Clean up expired partner codes (should be run periodically)
  Future<void> cleanupExpiredCodes() async {
    try {
      final now = Timestamp.now();

      final expiredCodes = await _firestore
          .collection(partnerCodesCollection)
          .where('expiresAt', isLessThan: now)
          .where('used', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (final doc in expiredCodes.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      // Silently fail - cleanup is not critical
    }
  }

  // ==================== EVENT CRUD OPERATIONS ====================

  /// Create a new event
  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _firestore.collection(eventsCollection).add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Error creating event: $e';
    }
  }

  /// Update an existing event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection(eventsCollection)
          .doc(event.eventId)
          .update(event.toFirestore());
    } catch (e) {
      throw 'Error updating event: $e';
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(eventsCollection).doc(eventId).delete();
    } catch (e) {
      throw 'Error deleting event: $e';
    }
  }

  /// Get a single event by ID
  Future<EventModel?> getEvent(String eventId) async {
    try {
      final doc = await _firestore.collection(eventsCollection).doc(eventId).get();

      if (!doc.exists) return null;

      return EventModel.fromFirestore(doc);
    } catch (e) {
      throw 'Error fetching event: $e';
    }
  }

  /// Get all events for a specific user
  Future<List<EventModel>> getUserEvents(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(eventsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('startTime')
          .get();

      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Error fetching user events: $e';
    }
  }

  /// Get events for a specific date range (for week view)
  /// Includes events from both the user and their partner
  Future<List<EventModel>> getEventsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get current user data to find partner
      final userData = await getUserData(userId);
      final partnerId = userData?.partnerId;

      // Query events for user and partner in date range
      final userIds = partnerId != null ? [userId, partnerId] : [userId];

      final snapshot = await _firestore
          .collection(eventsCollection)
          .where('userId', whereIn: userIds)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThan: Timestamp.fromDate(endDate))
          .orderBy('startTime')
          .get();

      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Error fetching events for date range: $e';
    }
  }

  /// Get events for a specific week (Monday to Sunday)
  Future<List<EventModel>> getEventsForWeek(String userId, DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return getEventsForDateRange(userId, weekStart, weekEnd);
  }

  /// Stream of events for a specific user (real-time updates)
  Stream<List<EventModel>> userEventsStream(String userId) {
    return _firestore
        .collection(eventsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    });
  }

  /// Stream of events for a date range (real-time updates)
  /// Includes events from both user and partner
  Stream<List<EventModel>> eventsForDateRangeStream(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async* {
    // Get current user data to find partner
    final userData = await getUserData(userId);
    final partnerId = userData?.partnerId;

    // Query events for user and partner in date range
    final userIds = partnerId != null ? [userId, partnerId] : [userId];

    yield* _firestore
        .collection(eventsCollection)
        .where('userId', whereIn: userIds)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startTime', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    });
  }

  /// Get events for both user and partner
  Future<List<EventModel>> getCombinedEvents(String userId) async {
    try {
      final userData = await getUserData(userId);
      final partnerId = userData?.partnerId;

      if (partnerId == null) {
        // No partner, just return user events
        return getUserEvents(userId);
      }

      // Get events for both users
      final userIds = [userId, partnerId];
      final snapshot = await _firestore
          .collection(eventsCollection)
          .where('userId', whereIn: userIds)
          .orderBy('startTime')
          .get();

      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Error fetching combined events: $e';
    }
  }

  // ==================== SHIFT TEMPLATE CRUD OPERATIONS ====================

  /// Create a new shift template
  Future<String> createShiftTemplate(ShiftTemplate template) async {
    try {
      final docRef = await _firestore
          .collection(shiftTemplatesCollection)
          .add(template.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Error creating shift template: $e';
    }
  }

  /// Update an existing shift template
  Future<void> updateShiftTemplate(ShiftTemplate template) async {
    try {
      await _firestore
          .collection(shiftTemplatesCollection)
          .doc(template.id)
          .update(template.toFirestore());
    } catch (e) {
      throw 'Error updating shift template: $e';
    }
  }

  /// Delete a shift template
  Future<void> deleteShiftTemplate(String templateId) async {
    try {
      await _firestore
          .collection(shiftTemplatesCollection)
          .doc(templateId)
          .delete();
    } catch (e) {
      throw 'Error deleting shift template: $e';
    }
  }

  /// Get a single shift template by ID
  Future<ShiftTemplate?> getShiftTemplate(String templateId) async {
    try {
      final doc = await _firestore
          .collection(shiftTemplatesCollection)
          .doc(templateId)
          .get();

      if (!doc.exists) return null;

      return ShiftTemplate.fromFirestore(doc);
    } catch (e) {
      throw 'Error fetching shift template: $e';
    }
  }

  /// Get all shift templates for a specific user
  Future<List<ShiftTemplate>> getUserShiftTemplates(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(shiftTemplatesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => ShiftTemplate.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching user shift templates: $e';
    }
  }

  /// Batch update the sort order of multiple shift templates
  Future<void> reorderShiftTemplates(List<ShiftTemplate> templates) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < templates.length; i++) {
        final updatedTemplate = templates[i].copyWith(
          sortOrder: i,
          updatedAt: DateTime.now(),
        );

        final docRef = _firestore
            .collection(shiftTemplatesCollection)
            .doc(updatedTemplate.id);

        batch.update(docRef, updatedTemplate.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw 'Error reordering shift templates: $e';
    }
  }

  /// Stream of shift templates for a specific user (real-time updates)
  Stream<List<ShiftTemplate>> userShiftTemplatesStream(String userId) {
    return _firestore
        .collection(shiftTemplatesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShiftTemplate.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // WORKPLACE METHODS
  // ============================================================================

  /// Create a new workplace for the user
  Future<WorkplaceModel> createWorkplace({
    required String userId,
    required String name,
    required int order,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = _firestore.collection(workplacesCollection).doc();

      final workplace = WorkplaceModel(
        workplaceId: docRef.id,
        userId: userId,
        name: name,
        order: order,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(workplace.toFirestore());
      return workplace;
    } catch (e) {
      throw 'Error creating workplace: $e';
    }
  }

  /// Update an existing workplace
  Future<void> updateWorkplace(String workplaceId, {String? name, int? order}) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updates['name'] = name;
      if (order != null) updates['order'] = order;

      await _firestore
          .collection(workplacesCollection)
          .doc(workplaceId)
          .update(updates);
    } catch (e) {
      throw 'Error updating workplace: $e';
    }
  }

  /// Delete a workplace
  Future<void> deleteWorkplace(String workplaceId) async {
    try {
      await _firestore.collection(workplacesCollection).doc(workplaceId).delete();
    } catch (e) {
      throw 'Error deleting workplace: $e';
    }
  }

  /// Get all workplaces for a specific user
  Future<List<WorkplaceModel>> getUserWorkplaces(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(workplacesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => WorkplaceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching user workplaces: $e';
    }
  }

  /// Stream of workplaces for a specific user (real-time updates)
  Stream<List<WorkplaceModel>> userWorkplacesStream(String userId) {
    return _firestore
        .collection(workplacesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkplaceModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Batch update the order of multiple workplaces
  Future<void> reorderWorkplaces(List<WorkplaceModel> workplaces) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < workplaces.length; i++) {
        final updatedWorkplace = workplaces[i].copyWith(
          order: i,
          updatedAt: DateTime.now(),
        );

        final docRef = _firestore
            .collection(workplacesCollection)
            .doc(updatedWorkplace.workplaceId);

        batch.update(docRef, updatedWorkplace.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw 'Error reordering workplaces: $e';
    }
  }

  /// Initialize default workplaces for a new user
  Future<List<WorkplaceModel>> initializeDefaultWorkplaces(String userId) async {
    try {
      final workplaces = <WorkplaceModel>[];

      // Create first default workplace
      final defaultWorkplace = await createWorkplace(
        userId: userId,
        name: 'My Workplace',
        order: 0,
      );
      workplaces.add(defaultWorkplace);

      return workplaces;
    } catch (e) {
      throw 'Error initializing default workplaces: $e';
    }
  }
}
