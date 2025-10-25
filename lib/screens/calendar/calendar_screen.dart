import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
            child: _buildCalendarGrid(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add event screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add event coming soon!')),
          );
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
  Widget _buildCalendarGrid(ThemeData theme) {
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
                return Expanded(
                  child: _buildDayColumn(day, theme),
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

  /// Build a single day column
  Widget _buildDayColumn(DateTime day, ThemeData theme) {
    final today = DateTime.now();
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;

    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : null,
        border: Border(
          right: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Hour rows
          ...List.generate(24, (hour) {
            return Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: Center(
                child: hour == 12
                    ? Text(
                        'No events',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
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
