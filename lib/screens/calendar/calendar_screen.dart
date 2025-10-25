import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../event/add_event_screen.dart';
import '../../providers/event_provider.dart';
import '../../models/event_model.dart';

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

    // Watch events for the current week
    final eventsAsync = ref.watch(eventsStreamProvider(_weekStart));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
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
              data: (events) => _buildCalendarGrid(theme, events),
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
  Widget _buildCalendarGrid(ThemeData theme, List<EventModel> events) {
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
                  child: _buildDayColumn(day, theme, dayEvents),
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
  Widget _buildDayColumn(DateTime day, ThemeData theme, List<EventModel> events) {
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

            return Positioned(
              top: top,
              left: 2,
              right: 2,
              height: height.clamp(20.0, double.infinity),
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to event details/edit screen
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(event.title),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start: ${DateFormat('h:mm a').format(event.startTime)}'),
                          Text('End: ${DateFormat('h:mm a').format(event.endTime)}'),
                          if (event.notes != null) ...[
                            const SizedBox(height: 8),
                            Text('Notes: ${event.notes}'),
                          ],
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: eventColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: eventColor, width: 1),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}
