import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';

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
    Colors.red,
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
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate change
      } else {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete event. Please try again.')),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
      }
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

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update event. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          if (!_isDeleting)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete),
              color: Colors.red,
              tooltip: 'Delete Event',
            ),
          TextButton(
            onPressed: _isDeleting ? null : _saveEvent,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g., Morning Shift, Night Shift',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
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
                  Text('Start', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(dateFormat.format(_startDate)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(context, true),
                          icon: const Icon(Icons.access_time),
                          label: Text(_startTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // End Date & Time
                  Text('End', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(dateFormat.format(_endDate)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(context, false),
                          icon: const Icon(Icons.access_time),
                          label: Text(_endTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Color picker
                  Text('Color', style: theme.textTheme.titleMedium),
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
                                ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add any additional details',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delete button
                  OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Event'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
