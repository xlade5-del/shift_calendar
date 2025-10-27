import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../event/add_event_screen.dart';
import '../event/edit_event_screen.dart';
import 'free_time_finder_screen.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/event_model.dart';
import '../../utils/conflict_detector.dart';

/// Calendar week view showing both partners' schedules
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedWeek = DateTime.now();

  /// Get the start of the week (Monday)
  DateTime get _weekStart {
    final now = _selectedWeek;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Get list of days for the current week
  List<DateTime> get _weekDays {
    return List.generate(
      7,
      (index) => _weekStart.add(Duration(days: index)),
    );
  }

  /// Navigate to previous week
  void _previousWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
    });
  }

  /// Navigate to next week
  void _nextWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.add(const Duration(days: 7));
    });
  }

  /// Reset to current week
  void _goToToday() {
    setState(() {
      _selectedWeek = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentWeek = _isCurrentWeek();
    final currentUser = ref.watch(currentFirebaseUserProvider);

    // Watch events for the current week
    final eventsAsync = ref.watch(eventsStreamProvider(_weekStart));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          // Free Time Finder button
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FreeTimeFinderScreen(),
                ),
              );
            },
            icon: const Icon(Icons.favorite),
            tooltip: 'Find Free Time',
          ),
          // Conflict warning badge
          eventsAsync.when(
            data: (events) {
              if (currentUser == null) return const SizedBox.shrink();

              final conflicts = ConflictDetector.getConflictPairs(
                events,
                currentUser.uid,
              );

              if (conflicts.isEmpty) return const SizedBox.shrink();

              return IconButton(
                onPressed: () => _showConflictsDialog(conflicts),
                icon: Badge(
                  label: Text('${conflicts.length}'),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.warning, color: Colors.orange),
                ),
                tooltip: 'View schedule conflicts',
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          if (!isCurrentWeek)
            TextButton(
              onPressed: _goToToday,
              child: const Text('Today'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Week Navigation Header
          _buildWeekNavigationHeader(theme),

          // Day Headers
          _buildDayHeaders(theme),

          // Calendar Grid
          Expanded(
            child: eventsAsync.when(
              data: (events) => _buildCalendarGrid(theme, events, currentUser),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading events: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEventScreen(initialDate: _selectedWeek),
            ),
          );

          // If event was created successfully, show success message
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event added to calendar!')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build week navigation header with arrows and date range
  Widget _buildWeekNavigationHeader(ThemeData theme) {
    final dateFormat = DateFormat('MMM d');
    final weekEnd = _weekStart.add(const Duration(days: 6));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousWeek,
            tooltip: 'Previous week',
          ),
          Text(
            '${dateFormat.format(_weekStart)} - ${dateFormat.format(weekEnd)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextWeek,
            tooltip: 'Next week',
          ),
        ],
      ),
    );
  }

  /// Build day headers row
  Widget _buildDayHeaders(ThemeData theme) {
    final dayFormat = DateFormat('E d'); // e.g., "Mon 25"
    final today = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: _weekDays.map((day) {
          final isToday = day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: isToday
                  ? BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                    )
                  : null,
              child: Text(
                dayFormat.format(day),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isToday
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build calendar grid showing days and time slots
  Widget _buildCalendarGrid(ThemeData theme, List<EventModel> events, User? currentUser) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time labels column
          _buildTimeLabels(theme),

          // Day columns
          Expanded(
            child: Row(
              children: _weekDays.map((day) {
                // Filter events for this specific day
                final dayEvents = events.where((event) {
                  return event.startTime.year == day.year &&
                      event.startTime.month == day.month &&
                      event.startTime.day == day.day;
                }).toList();

                return Expanded(
                  child: _buildDayColumn(day, theme, dayEvents, events, currentUser),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build time labels column (showing hours)
  Widget _buildTimeLabels(ThemeData theme) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        children: List.generate(24, (hour) {
          return Container(
            height: 60,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 8.0, top: 4.0),
            child: Text(
              hour == 0 ? '12 AM' : hour < 12 ? '$hour AM' : hour == 12 ? '12 PM' : '${hour - 12} PM',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Build a single day column with events
  Widget _buildDayColumn(
    DateTime day,
    ThemeData theme,
    List<EventModel> events,
    List<EventModel> allEvents,
    User? currentUser,
  ) {
    final today = DateTime.now();
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;

    const hourHeight = 60.0;

    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : null,
        border: Border(
          right: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Stack(
        children: [
          // Background grid (hour rows)
          Column(
            children: List.generate(24, (hour) {
              return Container(
                height: hourHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                  ),
                ),
              );
            }),
          ),

          // Events overlay
          ...events.map((event) {
            // Calculate position and height based on start/end times
            final startHour = event.startTime.hour + event.startTime.minute / 60.0;
            final endHour = event.endTime.hour + event.endTime.minute / 60.0;
            final top = startHour * hourHeight;
            final height = (endHour - startHour) * hourHeight;

            // Parse color from hex string
            final colorValue = int.parse(event.color.replaceFirst('#', ''), radix: 16);
            final eventColor = Color(0xFF000000 | colorValue);

            // Check if this event has conflicts
            final hasConflict = currentUser != null &&
                ConflictDetector.hasConflict(event, allEvents);

            return Positioned(
              top: top,
              left: 2,
              right: 2,
              height: height.clamp(20.0, double.infinity),
              child: GestureDetector(
                onTap: () {
                  _showEventDetails(event, allEvents);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: eventColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: hasConflict ? Colors.red : eventColor,
                      width: hasConflict ? 2.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasConflict)
                            const Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 14,
                            ),
                        ],
                      ),
                      if (height > 30)
                        Text(
                          '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Show event details dialog with edit/delete options
  Future<void> _showEventDetails(EventModel event, List<EventModel> allEvents) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isUserEvent = currentUser?.uid == event.userId;

    // Check for conflicts
    final conflictingEvents = ConflictDetector.findConflictsForEvent(
      event,
      allEvents.where((e) => e.userId != event.userId).toList(),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(DateFormat('EEE, MMM d, yyyy').format(event.startTime)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}'),
              ],
            ),
            if (event.notes != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(child: Text(event.notes!)),
                ],
              ),
            ],
            if (!isUserEvent) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text("Partner's Event", style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ],
            // Show conflict warning
            if (conflictingEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Schedule Conflict!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...conflictingEvents.map((conflictEvent) {
                return Padding(
                  padding: const EdgeInsets.only(left: 24, top: 4),
                  child: Text(
                    '• ${conflictEvent.title} (${DateFormat('h:mm a').format(conflictEvent.startTime)} - ${DateFormat('h:mm a').format(conflictEvent.endTime)})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
          if (isUserEvent)
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop('edit'),
              icon: const Icon(Icons.edit),
              label: const Text('EDIT'),
            ),
        ],
      ),
    );

    // If user clicked Edit, navigate to EditEventScreen
    if (result == 'edit' && mounted) {
      final editResult = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditEventScreen(event: event),
        ),
      );

      // If event was updated/deleted, show success message
      if (editResult == true && mounted) {
        // Event was updated or deleted, calendar will auto-update via stream
      }
    }
  }

  /// Check if currently viewing the current week
  bool _isCurrentWeek() {
    final now = DateTime.now();
    final nowWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final nowWeekStartDate =
        DateTime(nowWeekStart.year, nowWeekStart.month, nowWeekStart.day);

    return _weekStart.year == nowWeekStartDate.year &&
        _weekStart.month == nowWeekStartDate.month &&
        _weekStart.day == nowWeekStartDate.day;
  }

  /// Show dialog listing all schedule conflicts
  Future<void> _showConflictsDialog(List<ConflictPair> conflicts) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 12),
            const Text('Schedule Conflicts'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ConflictDetector.getConflictSummary(conflicts),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You and your partner have overlapping shifts:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              ...conflicts.map((conflict) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(conflict.userEvent.startTime),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Your event
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${conflict.userEvent.title}\n${DateFormat('h:mm a').format(conflict.userEvent.startTime)} - ${DateFormat('h:mm a').format(conflict.userEvent.endTime)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Partner event
                        Row(
                          children: [
                            const Icon(Icons.people, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${conflict.partnerEvent.title}\n${DateFormat('h:mm a').format(conflict.partnerEvent.startTime)} - ${DateFormat('h:mm a').format(conflict.partnerEvent.endTime)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Overlap duration
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, size: 12, color: Colors.red[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Overlap: ${conflict.overlapTimeRange}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}
