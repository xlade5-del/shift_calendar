import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_colors.dart';

/// Screen for editing an existing calendar event/shift
class EditEventScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late Color _selectedColor;

  // Predefined color options for shifts
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    AppColors.error,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    // Pre-populate fields with existing event data
    _titleController = TextEditingController(text: widget.event.title);
    _notesController = TextEditingController(text: widget.event.notes ?? '');

    _startDate = DateTime(
      widget.event.startTime.year,
      widget.event.startTime.month,
      widget.event.startTime.day,
    );
    _startTime = TimeOfDay.fromDateTime(widget.event.startTime);

    _endDate = DateTime(
      widget.event.endTime.year,
      widget.event.endTime.month,
      widget.event.endTime.day,
    );
    _endTime = TimeOfDay.fromDateTime(widget.event.endTime);

    // Parse color from hex string
    _selectedColor = _parseColor(widget.event.color);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Parse color from hex string
  Color _parseColor(String hexColor) {
    try {
      // Remove # if present
      final hex = hexColor.replaceAll('#', '');
      // Add FF for opacity if not present
      final colorInt = int.parse('FF$hex', radix: 16);
      final color = Color(colorInt);

      // Find closest matching color from options
      return _colorOptions.reduce((a, b) {
        final aDiff = (a.value - color.value).abs();
        final bDiff = (b.value - color.value).abs();
        return aDiff < bDiff ? a : b;
      });
    } catch (e) {
      return Colors.blue; // Default fallback
    }
  }

  /// Combine date and time into a single DateTime
  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Show date picker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // If start date is after end date, adjust end date
          if (_combineDateTime(_startDate, _startTime)
              .isAfter(_combineDateTime(_endDate, _endTime))) {
            _endDate = pickedDate;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  /// Show time picker
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  /// Show delete confirmation dialog
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Delete Event', style: TextStyle(color: AppColors.textDark)),
        content: Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL', style: TextStyle(color: AppColors.textDark)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteEvent();
    }
  }

  /// Delete the event
  Future<void> _deleteEvent() async {
    setState(() {
      _isDeleting = true;
    });

    final eventNotifier = ref.read(eventStateNotifierProvider.notifier);
    final success = await eventNotifier.deleteEvent(widget.event.eventId);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true); // Return true to indicate change
      } else {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  /// Validate and save event
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Combine date and time
    final startDateTime = _combineDateTime(_startDate, _startTime);
    final endDateTime = _combineDateTime(_endDate, _endTime);

    // Validate times
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      return;
    }

    // Create updated event model
    final updatedEvent = EventModel(
      eventId: widget.event.eventId,
      userId: widget.event.userId,
      title: _titleController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      source: widget.event.source,
      icalUid: widget.event.icalUid,
      version: widget.event.version,
      createdAt: widget.event.createdAt,
      updatedAt: DateTime.now(),
    );

    // Update event
    final eventNotifier = ref.read(eventStateNotifierProvider.notifier);
    final success = await eventNotifier.updateEvent(updatedEvent);

    if (mounted && success) {
      Navigator.of(context).pop(true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Edit Event',
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
          if (!_isDeleting)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete),
              color: AppColors.error,
              tooltip: 'Delete Event',
            ),
          TextButton(
            onPressed: _isDeleting ? null : _saveEvent,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isDeleting
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: AppColors.textGrey),
                      hintText: 'e.g., Morning Shift, Night Shift',
                      hintStyle: TextStyle(color: AppColors.textGrey),
                      filled: true,
                      fillColor: AppColors.white,
                      prefixIcon: Icon(Icons.title, color: AppColors.primaryTeal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.textLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.textLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Start Date & Time
                  Text('Start', style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, true),
                          icon: Icon(Icons.calendar_today, color: AppColors.primaryTeal),
                          label: Text(
                            dateFormat.format(_startDate),
                            style: TextStyle(color: AppColors.textDark),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryTeal, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(context, true),
                          icon: Icon(Icons.access_time, color: AppColors.primaryTeal),
                          label: Text(
                            _startTime.format(context),
                            style: TextStyle(color: AppColors.textDark),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryTeal, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // End Date & Time
                  Text('End', style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, false),
                          icon: Icon(Icons.calendar_today, color: AppColors.primaryTeal),
                          label: Text(
                            dateFormat.format(_endDate),
                            style: TextStyle(color: AppColors.textDark),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryTeal, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(context, false),
                          icon: Icon(Icons.access_time, color: AppColors.primaryTeal),
                          label: Text(
                            _endTime.format(context),
                            style: TextStyle(color: AppColors.textDark),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryTeal, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Color picker
                  Text('Color', style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: AppColors.textDark, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: AppColors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      labelStyle: TextStyle(color: AppColors.textGrey),
                      hintText: 'Add any additional details',
                      hintStyle: TextStyle(color: AppColors.textGrey),
                      filled: true,
                      fillColor: AppColors.white,
                      prefixIcon: Icon(Icons.notes, color: AppColors.primaryTeal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.textLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.textLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                      ),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  FilledButton.icon(
                    onPressed: _saveEvent,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delete button
                  OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Event'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
