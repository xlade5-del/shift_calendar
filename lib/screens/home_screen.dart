import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/workplace_provider.dart';
import '../models/event_model.dart';
import '../models/workplace_model.dart';
import '../utils/app_colors.dart';
import '../utils/conflict_detector.dart';
import 'partner/partner_invite_screen.dart';
import 'partner/partner_accept_screen.dart';
import 'partner/partner_management_screen.dart';
import 'calendar/calendar_screen.dart';
import 'settings/notification_settings_screen.dart';
import 'settings/ical_import_screen.dart';
import 'event/add_event_screen.dart';
import 'event/edit_event_screen.dart';
import 'shifts/available_shifts_screen.dart';
import 'shifts/shift_configuration_screen.dart';
import '../models/shift_template_model.dart';
import '../providers/shift_template_provider.dart';
import '../services/firestore_service.dart';

/// Redesigned home screen with month calendar view
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});


  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedTabIndex = 0; // 0: Month, 1: Year, 2: Summary
  int _selectedBottomIndex = 2; // 0: Paint, 1: Edit, 2: Shifts

  // Paint mode state
  bool _isPaintMode = false;
  ShiftTemplate? _selectedPaintTemplate;
  bool _isEraseMode = false;

  /// Get the first day of the month
  DateTime get _monthStart {
    return DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  /// Get the last day of the month
  DateTime get _monthEnd {
    return DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
  }

  /// Get all days to display in the month view (including days from prev/next months)
  List<DateTime> get _calendarDays {
    final firstWeekday = _monthStart.weekday; // 1 = Monday, 7 = Sunday
    final daysInMonth = _monthEnd.day;

    // Start from Monday (1)
    final leadingEmptyDays = firstWeekday - 1;

    final days = <DateTime>[];

    // Add days from previous month
    if (leadingEmptyDays > 0) {
      final previousMonthEnd = DateTime(_selectedDate.year, _selectedDate.month, 0);
      final previousMonthLastDay = previousMonthEnd.day;

      for (int i = leadingEmptyDays - 1; i >= 0; i--) {
        days.add(DateTime(
          previousMonthEnd.year,
          previousMonthEnd.month,
          previousMonthLastDay - i,
        ));
      }
    }

    // Add actual days of the current month
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(_selectedDate.year, _selectedDate.month, day));
    }

    // Add days from next month to complete the grid
    final totalCells = days.length;
    final remainingCells = (7 - (totalCells % 7)) % 7;

    for (int i = 1; i <= remainingCells; i++) {
      days.add(DateTime(_selectedDate.year, _selectedDate.month + 1, i));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final user = ref.watch(currentFirebaseUserProvider);
    final filteredEvents = ref.watch(filteredMonthEventsProvider(_monthStart));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header with Workplace Selector
            _buildTopHeader(),

            // Tab Navigation (Month / Year / Summary)
            _buildTabNavigation(),

            // Calendar Content
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildMonthCalendarView(filteredEvents)
                  : _selectedTabIndex == 1
                      ? _buildYearView()
                      : _buildSummaryView(userAsync, user),
            ),

            // Bottom Navigation or Paint Toolbar
            _isPaintMode ? _buildPaintToolbar() : _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Workplace Selector
          Expanded(
            child: GestureDetector(
              onTap: _showWorkplaceSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final selectedWorkplace = ref.watch(selectedWorkplaceProvider);
                          return Text(
                            selectedWorkplace?.name ?? 'My Workplace',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          );
                        },
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Share Button
          IconButton(
            icon: Icon(Icons.share, color: AppColors.primaryTeal),
            onPressed: () {},
          ),

          // Settings Button
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textDark),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton('OCTOBER', 0),
          _buildTabButton('2025', 1),
          _buildTabButton('SUMMARY', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;

    // Update the label based on current date if needed
    String displayLabel = label;
    if (index == 0) {
      displayLabel = DateFormat('MMMM').format(_selectedDate).toUpperCase();
    } else if (index == 1) {
      displayLabel = DateFormat('yyyy').format(_selectedDate);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCalendarView(List<EventModel> events) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Navigation Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.textDark),
                onPressed: _previousMonth,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.textDark),
                onPressed: _nextMonth,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weekday Headers
          Row(
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),

          // Calendar Grid - expands to fill available space
          Expanded(
            child: _buildCalendarGrid(events),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<EventModel> events) {
    final days = _calendarDays;
    final rows = (days.length / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(7, (colIndex) {
              final dayIndex = rowIndex * 7 + colIndex;
              if (dayIndex >= days.length) return const Expanded(child: SizedBox());

              final day = days[dayIndex];

              // Filter events for this day
              final dayEvents = events.where((event) {
                return event.startTime.year == day.year &&
                    event.startTime.month == day.month &&
                    event.startTime.day == day.day;
              }).toList();

              return Expanded(
                child: _buildCalendarDay(day, dayEvents),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarDay(DateTime day, List<EventModel> events) {
    final isToday = DateTime.now().year == day.year &&
        DateTime.now().month == day.month &&
        DateTime.now().day == day.day;
    final isWeekend = day.weekday == 6 || day.weekday == 7;
    final isCurrentMonth = day.month == _selectedDate.month;
    final isOverflowDate = !isCurrentMonth;

    // Creamy shadowy colors for overflow dates
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isOverflowDate) {
      // Creamy, faded appearance for dates from other months
      backgroundColor = const Color(0xFFFAF9F7); // Very light cream
      textColor = const Color(0xFFB8B5B2); // Soft grey-beige
      borderColor = const Color(0xFFEAE8E6); // Light border
    } else {
      // Normal styling for current month
      backgroundColor = isWeekend ? AppColors.lightPeach.withOpacity(0.3) : Colors.white;
      textColor = isWeekend ? AppColors.peach : AppColors.textDark;
      borderColor = isToday ? AppColors.primaryTeal : AppColors.divider;
    }

    return GestureDetector(
      onTap: () {
        if (_isPaintMode) {
          _handlePaintModeTap(day, events);
        } else {
          _showDayEvents(day, events);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: isToday && isCurrentMonth ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Day number - smaller, cleaner
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isToday && isCurrentMonth ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            // Events section - fills remaining space
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: events.isEmpty
                    ? const SizedBox()
                    : _buildEventsList(events),
              ),
            ),
            // Show overflow indicator
            if (events.length > 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '+${events.length - 2}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<EventModel> events) {
    // If there's a painted shift template event, show it prominently
    final userAsync = ref.watch(currentUserDataProvider);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: events.length > 2 ? 2 : events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final colorValue = int.parse(event.color.replaceFirst('#', ''), radix: 16);
        final eventColor = Color(0xFF000000 | colorValue);

        // Check if this is a painted template event
        final isPaintedTemplate = event.notes?.contains('Painted from template:') ?? false;
        String? templateAbbreviation;
        if (isPaintedTemplate && event.notes != null) {
          final match = RegExp(r'Painted from template: (.+)').firstMatch(event.notes!);
          templateAbbreviation = match?.group(1);
        }

        // Format time
        final startTime = DateFormat('HH:mm').format(event.startTime);
        final endTime = DateFormat('HH:mm').format(event.endTime);
        final timeRange = '$startTime-$endTime';

        // Build display based on whether it's a painted template or regular event
        if (isPaintedTemplate && templateAbbreviation != null) {
          // Painted shift template - show template name, time, and owner
          return Container(
            margin: const EdgeInsets.only(bottom: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: eventColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Template abbreviation (prominent)
                Text(
                  templateAbbreviation,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                // Time range
                Text(
                  timeRange,
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                    height: 1.1,
                  ),
                  maxLines: 1,
                ),
                // Owner name
                userAsync.when(
                  data: (userData) => userData != null
                      ? Text(
                          userData.displayName ?? 'Me',
                          style: TextStyle(
                            fontSize: 6,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white.withOpacity(0.9),
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          );
        } else {
          // Regular event - show title only
          return Container(
            margin: const EdgeInsets.only(bottom: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
            decoration: BoxDecoration(
              color: eventColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              event.title,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      },
    );
  }

  Widget _buildYearView() {
    final year = _selectedDate.year;
    final yearEventsAsync = ref.watch(eventsStreamProvider(DateTime(year, 1, 1)));

    return yearEventsAsync.when(
      data: (events) => Column(
        children: [
          // Year Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildYearNavigationButton('${year - 1}', () {
                  setState(() {
                    _selectedDate = DateTime(year - 1, _selectedDate.month);
                  });
                }),
                const SizedBox(width: 16),
                _buildYearNavigationButton('${year + 1}', () {
                  setState(() {
                    _selectedDate = DateTime(year + 1, _selectedDate.month);
                  });
                }),
              ],
            ),
          ),

          // 12 Months Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95, // More compact, slightly rectangular
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final monthDate = DateTime(year, month, 1);
                final monthEvents = events.where((event) {
                  return event.startTime.year == year && event.startTime.month == month;
                }).toList();
                return _buildMiniMonthCalendar(monthDate, monthEvents);
              },
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading year view: $error'),
      ),
    );
  }

  Widget _buildYearNavigationButton(String year, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          year,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2E),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMonthCalendar(DateTime monthDate, List<EventModel> events) {
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday

    // Build list of all days in month with padding
    final days = <DateTime?>[];
    for (int i = 0; i < firstWeekday - 1; i++) {
      days.add(null);
    }
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(monthDate.year, monthDate.month, day));
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Name
          Text(
            DateFormat('MMMM').format(monthDate).toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Weekday Headers
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 3),

          // Calendar Days Grid - more compact, rectangular boxes
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 1.5,
                mainAxisSpacing: 1.5,
                childAspectRatio: 1.2, // Slightly wider than tall for rectangular look
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                if (day == null) {
                  return const SizedBox.shrink();
                }

                // Find events for this day
                final dayEvents = events.where((event) {
                  return event.startTime.day == day.day;
                }).toList();

                // Determine color based on events
                Color bgColor = AppColors.lightCream; // Very light cream for empty days
                Color textColor = AppColors.textDark;

                if (dayEvents.isNotEmpty) {
                  // Use the first event's color
                  final eventColor = Color(int.parse(dayEvents.first.color.replaceFirst('#', '0xFF')));
                  bgColor = eventColor.withOpacity(0.9);
                  textColor = AppColors.white;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: dayEvents.isEmpty
                        ? AppColors.divider.withOpacity(0.3)
                        : Colors.transparent,
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: dayEvents.isNotEmpty ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryView(AsyncValue userAsync, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryTeal.withOpacity(0.2),
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF007AFF),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                userAsync.when(
                  data: (userData) => Column(
                    children: [
                      Text(
                        userData?.displayName ?? user?.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData?.email ?? user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Partner Section
          userAsync.when(
            data: (currentUserData) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    currentUserData?.partnerId != null ? 'Partner' : 'Partner Linking',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (currentUserData?.partnerId != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PartnerManagementScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.manage_accounts),
                      label: const Text('Manage Partner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PartnerInviteScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Invite Partner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PartnerAcceptScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Enter Partner Code'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Quick Actions Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickActionButton(
                  'View Week Calendar',
                  Icons.calendar_view_week,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CalendarScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickActionButton(
                  'Notification Settings',
                  Icons.notifications,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickActionButton(
                  'Sign Out',
                  Icons.logout,
                  () async {
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (shouldSignOut == true) {
                      final authNotifier = ref.read(authStateNotifierProvider.notifier);
                      await authNotifier.signOut();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTeal),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final filteredEvents = ref.watch(filteredMonthEventsProvider(_monthStart));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavButton('PAINT', 0, Icons.brush, events: filteredEvents),
          _buildBottomNavButton('CONFLICTS', 1, Icons.warning_amber_rounded, events: filteredEvents),
          _buildBottomNavButton('SHIFTS', 2, Icons.event, events: filteredEvents),
        ],
      ),
    );
  }

  Widget _buildBottomNavButton(String label, int index, IconData icon, {required List<EventModel> events}) {
    final isSelected = _selectedBottomIndex == index || (_isPaintMode && index == 0);

    // Calculate conflicts if this is the conflicts button
    int conflictCount = 0;
    if (index == 1 && label == 'CONFLICTS') {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        final conflicts = ConflictDetector.getConflictPairs(events, user.uid);
        conflictCount = conflicts.length;
      }
    }

    return Expanded(
      child: InkWell(
        onTap: () async {
          // Handle navigation based on button
          if (index == 0) { // Paint
            // Enter paint mode
            setState(() {
              _isPaintMode = true;
              _selectedBottomIndex = 0;
            });
          } else if (index == 1) { // Conflicts
            setState(() => _selectedBottomIndex = index);
            // Show conflicts dialog
            _showConflictsDialog();
          } else if (index == 2) { // Shifts
            setState(() => _selectedBottomIndex = index);
            // Show available shifts bottom sheet
            final result = await showModalBottomSheet<Map<String, dynamic>?>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) => AvailableShiftsScreen(
                  scrollController: scrollController,
                ),
              ),
            );

            print('Modal closed with result: $result');
            print('Mounted: $mounted');

            // Handle navigation based on result
            if (result != null && mounted) {
              print('Processing result action: ${result['action']}');
              if (result['action'] == 'create') {
                print('Navigating to create shift screen');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ShiftConfigurationScreen(),
                  ),
                );
              } else if (result['action'] == 'edit') {
                print('Navigating to edit shift screen');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShiftConfigurationScreen(
                      template: result['template'] as ShiftTemplate,
                    ),
                  ),
                );
              }
            } else {
              print('Result is null or not mounted. Result: $result, Mounted: $mounted');
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show badge for conflicts button if there are conflicts
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: index == 1 && conflictCount > 0
                        ? AppColors.error
                        : (isSelected ? AppColors.primaryTeal : AppColors.textGrey),
                  ),
                  if (index == 1 && conflictCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$conflictCount',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: index == 1 && conflictCount > 0
                      ? AppColors.error
                      : (isSelected ? AppColors.primaryTeal : AppColors.textGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkplaceSelector() {
    final workplacesAsync = ref.read(workplacesStreamProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final workplacesAsync = ref.watch(workplacesStreamProvider);
            final selectedWorkplaceId = ref.watch(selectedWorkplaceIdProvider);

            return workplacesAsync.when(
              data: (workplaces) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Workplace',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (workplaces.length < 5)
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: AppColors.primaryTeal),
                              onPressed: () {
                                Navigator.pop(context);
                                _showAddWorkplaceDialog();
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (workplaces.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              const Icon(Icons.business, size: 48, color: AppColors.textGrey),
                              const SizedBox(height: 16),
                              const Text(
                                'No workplaces yet',
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showAddWorkplaceDialog();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Workplace'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryTeal,
                                  foregroundColor: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...workplaces.map((workplace) =>
                          _buildWorkplaceOption(workplace, selectedWorkplaceId)),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(48.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error: $error'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkplaceOption(WorkplaceModel workplace, String? selectedId) {
    final isSelected = selectedId == workplace.workplaceId;

    return InkWell(
      onTap: () {
        ref.read(selectedWorkplaceIdProvider.notifier).select(workplace.workplaceId);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal.withOpacity(0.1) : AppColors.cream,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primaryTeal, width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.business,
              color: isSelected ? AppColors.primaryTeal : AppColors.textGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                workplace.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primaryTeal : AppColors.textDark,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: AppColors.textGrey,
              onPressed: () {
                Navigator.pop(context);
                _showEditWorkplaceDialog(workplace);
              },
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primaryTeal),
          ],
        ),
      ),
    );
  }

  void _showAddWorkplaceDialog() async {
    final workplacesAsync = ref.read(workplacesStreamProvider);
    final workplaces = workplacesAsync.value ?? [];

    if (workplaces.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 workplaces allowed')),
      );
      return;
    }

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Workplace'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Workplace name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              try {
                final operations = ref.read(workplaceOperationsProvider);
                await operations.createWorkplace(
                  controller.text.trim(),
                  workplaces.length,
                );
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditWorkplaceDialog(WorkplaceModel workplace) {
    final controller = TextEditingController(text: workplace.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Workplace'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Workplace name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final operations = ref.read(workplaceOperationsProvider);
                await operations.deleteWorkplace(workplace.workplaceId);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              try {
                final operations = ref.read(workplaceOperationsProvider);
                await operations.updateWorkplaceName(
                  workplace.workplaceId,
                  controller.text.trim(),
                );
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingsOption('Notification Settings', Icons.notifications, () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              }),
              _buildSettingsOption('Partner Management', Icons.people, () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PartnerManagementScreen(),
                  ),
                );
              }),
              _buildSettingsOption('iCal Import', Icons.cloud_download, () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const IcalImportScreen(),
                  ),
                );
              }),
              _buildSettingsOption('Week Calendar View', Icons.calendar_view_week, () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsOption(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTeal),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  void _showDayEvents(DateTime day, List<EventModel> events) {
    final currentUserData = ref.read(currentUserDataProvider);
    final partnerData = ref.read(partnerDataProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(day),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (events.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 48, color: AppColors.textGrey),
                            SizedBox(height: 16),
                            Text(
                              'No events scheduled',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final colorValue = int.parse(event.color.replaceFirst('#', ''), radix: 16);
                          final eventColor = Color(0xFF000000 | colorValue);

                          // Check if this is a painted template event
                          final isPaintedTemplate = event.notes?.contains('Painted from template:') ?? false;

                          // Get owner name
                          String? ownerName;
                          if (isPaintedTemplate) {
                            // Check current user data
                            final currentUserValue = currentUserData.value;
                            if (currentUserValue != null && event.userId == currentUserValue.uid) {
                              ownerName = (currentUserValue.displayName ?? 'User').toUpperCase();
                            } else {
                              // Check partner data
                              final partnerValue = partnerData.value;
                              if (partnerValue != null && event.userId == partnerValue.uid) {
                                ownerName = (partnerValue.displayName ?? 'Partner').toUpperCase();
                              }
                            }
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditEventScreen(event: event),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: eventColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: eventColor, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: eventColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                        // Show owner name for painted templates, otherwise show notes
                                        if (isPaintedTemplate && ownerName != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            ownerName!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textGrey,
                                              letterSpacing: 0.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else if (event.notes != null && event.notes!.isNotEmpty && !isPaintedTemplate) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            event.notes!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textGrey,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: eventColor),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEventScreen(initialDate: day),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Event'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showConflictsDialog() {
    final filteredEvents = ref.read(filteredMonthEventsProvider(_monthStart));
    final user = ref.read(authStateChangesProvider).value;
    final currentUserData = ref.read(currentUserDataProvider);
    final partnerData = ref.read(partnerDataProvider);

    if (user == null) return;

    final conflicts = ConflictDetector.getConflictPairs(filteredEvents, user.uid);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: conflicts.isEmpty ? AppColors.primaryTeal : AppColors.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    conflicts.isEmpty ? 'No Conflicts' : 'Schedule Conflicts',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: conflicts.isEmpty
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: AppColors.primaryTeal,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No scheduling conflicts found for this month.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: conflicts.length,
                      itemBuilder: (context, index) {
                        final conflict = conflicts[index];

                        // Get owner names
                        String userName = 'You';
                        String partnerName = 'Partner';

                        currentUserData.whenData((userData) {
                          if (userData != null) {
                            userName = userData.displayName ?? 'You';
                          }
                        });

                        partnerData.whenData((partner) {
                          if (partner != null) {
                            partnerName = partner.displayName ?? 'Partner';
                          }
                        });

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date
                              Text(
                                DateFormat('EEEE, MMM d').format(conflict.userEvent.startTime),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Your event
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: AppColors.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$userName: ',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${conflict.userEvent.title} (${DateFormat('h:mm a').format(conflict.userEvent.startTime)} - ${DateFormat('h:mm a').format(conflict.userEvent.endTime)})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Partner event
                              Row(
                                children: [
                                  Icon(Icons.people, size: 16, color: AppColors.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$partnerName: ',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${conflict.partnerEvent.title} (${DateFormat('h:mm a').format(conflict.partnerEvent.startTime)} - ${DateFormat('h:mm a').format(conflict.partnerEvent.endTime)})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Overlap info
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Overlap: ${conflict.overlapTimeRange}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildPaintToolbar() {
    final templatesAsync = ref.watch(userShiftTemplatesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close/Exit Paint Mode button
          GestureDetector(
            onTap: () {
              setState(() {
                _isPaintMode = false;
                _selectedPaintTemplate = null;
                _isEraseMode = false;
                _selectedBottomIndex = 2;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cream.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.darkTeal,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Scrollable template buttons
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Erase button
                  _buildEraseButton(),
                  const SizedBox(width: 8),

                  // Template buttons
                  templatesAsync.when(
                    data: (templates) {
                      if (templates.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'No shift templates. Create one in Shifts tab.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return Row(
                        children: templates
                            .map((template) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildTemplateButton(template),
                                ))
                            .toList(),
                      );
                    },
                    loading: () => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    error: (error, _) => Text(
                      'Error loading templates',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEraseButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEraseMode = !_isEraseMode;
          if (_isEraseMode) {
            _selectedPaintTemplate = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isEraseMode ? AppColors.cream : AppColors.cream.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: _isEraseMode ? Border.all(color: AppColors.peach, width: 2) : null,
        ),
        child: Text(
          'Erase',
          style: TextStyle(
            fontSize: 14,
            fontWeight: _isEraseMode ? FontWeight.bold : FontWeight.w600,
            color: AppColors.darkTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateButton(ShiftTemplate template) {
    final isSelected = _selectedPaintTemplate?.id == template.id;
    final backgroundColor = Color(int.parse(template.backgroundColor.replaceFirst('#', '0xFF')));
    final textColor = Color(int.parse(template.textColor.replaceFirst('#', '0xFF')));

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaintTemplate = template;
          _isEraseMode = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.peach, width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              template.abbreviation,
              style: TextStyle(
                fontSize: template.textSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (template.schedule != null && template.schedule!.isNotEmpty)
              Text(
                template.schedule!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(0.9),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handlePaintModeTap(DateTime day, List<EventModel> existingEvents) async {
    if (_isEraseMode) {
      // Erase all events on this day
      if (existingEvents.isEmpty) {
        return;
      }

      // Delete all events on this day
      final firestoreService = ref.read(firestoreServiceProvider);
      for (final event in existingEvents) {
        await firestoreService.deleteEvent(event.eventId);
      }
    } else if (_selectedPaintTemplate != null) {
      // Paint the selected template on this day
      final template = _selectedPaintTemplate!;
      final user = ref.read(authStateChangesProvider).value;

      if (user == null) {
        return;
      }

      // Parse schedule time if available, otherwise use default 9am-5pm
      DateTime startTime;
      DateTime endTime;

      if (template.schedule != null && template.schedule!.contains('-')) {
        // Try to parse schedule like "14:30-21:00" or "14.30-21.00"
        try {
          final parts = template.schedule!.split('-');
          final startParts = parts[0].trim().replaceAll('.', ':').split(':');
          final endParts = parts[1].trim().replaceAll('.', ':').split(':');

          startTime = DateTime(
            day.year,
            day.month,
            day.day,
            int.parse(startParts[0]),
            startParts.length > 1 ? int.parse(startParts[1]) : 0,
          );

          endTime = DateTime(
            day.year,
            day.month,
            day.day,
            int.parse(endParts[0]),
            endParts.length > 1 ? int.parse(endParts[1]) : 0,
          );
        } catch (e) {
          // If parsing fails, use default times
          startTime = DateTime(day.year, day.month, day.day, 9, 0);
          endTime = DateTime(day.year, day.month, day.day, 17, 0);
        }
      } else {
        // Default times: 9am to 5pm
        startTime = DateTime(day.year, day.month, day.day, 9, 0);
        endTime = DateTime(day.year, day.month, day.day, 17, 0);
      }

      // Get selected workplace ID
      final selectedWorkplaceId = ref.read(selectedWorkplaceIdProvider);

      // Create event from template
      final event = EventModel(
        eventId: '', // Will be generated by Firestore
        userId: user.uid,
        title: template.name,
        startTime: startTime,
        endTime: endTime,
        color: template.backgroundColor,
        notes: 'Painted from template: ${template.abbreviation}',
        source: EventSource.manual,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
        workplaceId: selectedWorkplaceId, // Add workplace ID so it appears in filtered view
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.createEvent(event);
    }
  }
}
