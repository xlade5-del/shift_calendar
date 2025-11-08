import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

/// Screen for finding mutual free time between partners
class FreeTimeFinderScreen extends ConsumerStatefulWidget {
  const FreeTimeFinderScreen({super.key});

  @override
  ConsumerState<FreeTimeFinderScreen> createState() => _FreeTimeFinderScreenState();
}

class _FreeTimeFinderScreenState extends ConsumerState<FreeTimeFinderScreen> {
  DateTime _selectedDate = DateTime.now();
  int _daysToCheck = 7; // Default to 7 days
  int _minimumHours = 2; // Minimum free time block in hours

  /// Get the start of the day
  DateTime _getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get the end of the day
  DateTime _getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Find free time slots between events
  List<FreeTimeSlot> _findFreeTimeSlots(
    List<EventModel> userEvents,
    List<EventModel> partnerEvents,
    DateTime startDate,
    int days,
    int minHours,
  ) {
    final freeSlots = <FreeTimeSlot>[];

    for (int i = 0; i < days; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final dayStart = _getStartOfDay(currentDate);
      final dayEnd = _getEndOfDay(currentDate);

      // Get all events for this day (both user and partner)
      final dayEvents = [
        ...userEvents,
        ...partnerEvents,
      ].where((event) {
        return event.startTime.isBefore(dayEnd) &&
            event.endTime.isAfter(dayStart);
      }).toList();

      // Sort events by start time
      dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Find gaps between events (free time)
      DateTime lastEndTime = dayStart;

      for (final event in dayEvents) {
        // Check if there's a gap before this event
        if (event.startTime.isAfter(lastEndTime)) {
          final gapDuration = event.startTime.difference(lastEndTime);
          if (gapDuration.inHours >= minHours) {
            freeSlots.add(FreeTimeSlot(
              startTime: lastEndTime,
              endTime: event.startTime,
            ));
          }
        }

        // Update last end time (considering overlapping events)
        if (event.endTime.isAfter(lastEndTime)) {
          lastEndTime = event.endTime;
        }
      }

      // Check if there's free time after the last event until end of day
      if (lastEndTime.isBefore(dayEnd)) {
        final gapDuration = dayEnd.difference(lastEndTime);
        if (gapDuration.inHours >= minHours) {
          freeSlots.add(FreeTimeSlot(
            startTime: lastEndTime,
            endTime: dayEnd,
          ));
        }
      }
    }

    return freeSlots;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentFirebaseUserProvider);
    final currentUserData = ref.watch(currentUserDataProvider);

    // Check if user has a partner
    final hasPartner = currentUserData.value?.partnerId != null;

    if (!hasPartner) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Free Time Finder',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: AppColors.textGrey.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Partner Linked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Link with your partner to find mutual free time.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Fetch events for the date range
    final eventsAsync = ref.watch(eventsStreamProvider(_selectedDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Free Time Finder',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppColors.textDark),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          if (currentUser == null) {
            return const Center(child: Text('Please log in'));
          }

          // Split events into user and partner events
          final userEvents =
              events.where((e) => e.userId == currentUser.uid).toList();
          final partnerEvents =
              events.where((e) => e.userId != currentUser.uid).toList();

          // Find free time slots
          final freeSlots = _findFreeTimeSlots(
            userEvents,
            partnerEvents,
            _selectedDate,
            _daysToCheck,
            _minimumHours,
          );

          return Column(
            children: [
              // Controls card
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                      // Days to check
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Days to check: $_daysToCheck',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 3, label: Text('3')),
                              ButtonSegment(value: 7, label: Text('7')),
                              ButtonSegment(value: 14, label: Text('14')),
                              ButtonSegment(value: 30, label: Text('30')),
                            ],
                            selected: {_daysToCheck},
                            onSelectionChanged: (Set<int> newSelection) {
                              setState(() {
                                _daysToCheck = newSelection.first;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Minimum hours
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Minimum free time: $_minimumHours hours',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 1, label: Text('1h')),
                              ButtonSegment(value: 2, label: Text('2h')),
                              ButtonSegment(value: 4, label: Text('4h')),
                              ButtonSegment(value: 8, label: Text('8h')),
                            ],
                            selected: {_minimumHours},
                            onSelectionChanged: (Set<int> newSelection) {
                              setState(() {
                                _minimumHours = newSelection.first;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Results
              Expanded(
                child: freeSlots.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: AppColors.textGrey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No Free Time Found',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Try adjusting the search settings or checking a different date range.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textGrey,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: freeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = freeSlots[index];
                          return _buildFreeTimeCard(slot);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading events: $error',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  /// Build a card for a free time slot
  Widget _buildFreeTimeCard(FreeTimeSlot slot) {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');
    final duration = slot.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.pink.withOpacity(0.15),
          child: Icon(
            Icons.favorite,
            color: Colors.pink[400],
            size: 24,
          ),
        ),
        title: Text(
          dateFormat.format(slot.startTime),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${timeFormat.format(slot.startTime)} - ${timeFormat.format(slot.endTime)}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${hours}h ${minutes}m',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  /// Show help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline),
            SizedBox(width: 12),
            Text('How it works'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Free Time Finder analyzes both your schedule and your partner\'s schedule to find times when you\'re both free.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Search Settings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Days to check: How many days ahead to search',
                style: TextStyle(height: 1.5),
              ),
              Text(
                '• Minimum free time: Minimum duration to show as a result',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Tip: If no results appear, try reducing the minimum free time or increasing the days to check.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }
}

/// Represents a free time slot
class FreeTimeSlot {
  final DateTime startTime;
  final DateTime endTime;

  FreeTimeSlot({
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}
