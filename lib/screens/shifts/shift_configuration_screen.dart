import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shift_template_model.dart';
import '../../providers/shift_template_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

class ShiftConfigurationScreen extends ConsumerStatefulWidget {
  final ShiftTemplate? template; // null if creating new, non-null if editing

  const ShiftConfigurationScreen({super.key, this.template});

  @override
  ConsumerState<ShiftConfigurationScreen> createState() =>
      _ShiftConfigurationScreenState();
}

class _ShiftConfigurationScreenState
    extends ConsumerState<ShiftConfigurationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _abbreviationController;

  Color _backgroundColor = const Color(0xFFFFC0CB); // Pink
  Color _textColor = Colors.black;
  double _textSize = 12.0;

  bool _isSaving = false;

  // Schedule tab state
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isSplitShift = false;
  TimeOfDay _splitStartTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _splitEndTime = const TimeOfDay(hour: 22, minute: 0);
  final TextEditingController _restTimeController = TextEditingController(text: '0');
  bool _calculateShiftTime = false;
  final TextEditingController _shiftHoursController = TextEditingController(text: '0');
  final TextEditingController _shiftMinutesController = TextEditingController(text: '0');

  // Alarms state
  bool _alarm1Enabled = false;
  TimeOfDay _alarm1Time = const TimeOfDay(hour: 6, minute: 0);
  bool _alarm2Enabled = false;
  TimeOfDay _alarm2Time = const TimeOfDay(hour: 7, minute: 0);

  // Incomes state
  final TextEditingController _perHourController = TextEditingController();
  final TextEditingController _perExtraHourController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize with existing template data if editing
    if (widget.template != null) {
      _nameController = TextEditingController(text: widget.template!.name);
      _abbreviationController = TextEditingController(text: widget.template!.abbreviation);
      _backgroundColor = _parseColor(widget.template!.backgroundColor);
      _textColor = _parseColor(widget.template!.textColor);
      _textSize = widget.template!.textSize;

      // Parse schedule if available (format: "HH:mm-HH:mm")
      if (widget.template!.schedule != null && widget.template!.schedule!.contains('-')) {
        try {
          final parts = widget.template!.schedule!.split('-');
          final startParts = parts[0].trim().split(':');
          final endParts = parts[1].trim().split(':');

          _startTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: startParts.length > 1 ? int.parse(startParts[1]) : 0,
          );

          _endTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: endParts.length > 1 ? int.parse(endParts[1]) : 0,
          );
        } catch (e) {
          // If parsing fails, keep default times (14:00-14:00)
        }
      }

      // Load split shift data
      _isSplitShift = widget.template!.isSplitShift;
      if (widget.template!.splitStartTime != null) {
        final parts = widget.template!.splitStartTime!.split(':');
        _splitStartTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: parts.length > 1 ? int.parse(parts[1]) : 0,
        );
      }
      if (widget.template!.splitEndTime != null) {
        final parts = widget.template!.splitEndTime!.split(':');
        _splitEndTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: parts.length > 1 ? int.parse(parts[1]) : 0,
        );
      }

      // Load rest time
      _restTimeController.text = widget.template!.restTimeMinutes.toString();

      // Load alarms
      _alarm1Enabled = widget.template!.alarm1Enabled;
      if (widget.template!.alarm1Time != null) {
        final parts = widget.template!.alarm1Time!.split(':');
        _alarm1Time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: parts.length > 1 ? int.parse(parts[1]) : 0,
        );
      }
      _alarm2Enabled = widget.template!.alarm2Enabled;
      if (widget.template!.alarm2Time != null) {
        final parts = widget.template!.alarm2Time!.split(':');
        _alarm2Time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: parts.length > 1 ? int.parse(parts[1]) : 0,
        );
      }

      // Load income data
      if (widget.template!.hourlyRate != null) {
        _perHourController.text = widget.template!.hourlyRate.toString();
      }
      if (widget.template!.extraHourlyRate != null) {
        _perExtraHourController.text = widget.template!.extraHourlyRate.toString();
      }
    } else {
      _nameController = TextEditingController(text: 'New');
      _abbreviationController = TextEditingController(text: 'New');
    }

    // Calculate initial shift time
    _updateShiftTimeCalculation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _abbreviationController.dispose();
    _restTimeController.dispose();
    _shiftHoursController.dispose();
    _shiftMinutesController.dispose();
    _perHourController.dispose();
    _perExtraHourController.dispose();
    super.dispose();
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _updateShiftTimeCalculation() {
    if (!_calculateShiftTime) return;

    // Convert TimeOfDay to minutes for easier calculation
    int startMinutes = _startTime.hour * 60 + _startTime.minute;
    int endMinutes = _endTime.hour * 60 + _endTime.minute;

    // Handle overnight shifts
    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Add 24 hours
    }

    int totalMinutes = endMinutes - startMinutes;

    // Add split shift duration if enabled
    if (_isSplitShift) {
      int splitStartMinutes = _splitStartTime.hour * 60 + _splitStartTime.minute;
      int splitEndMinutes = _splitEndTime.hour * 60 + _splitEndTime.minute;

      // Handle overnight split shifts
      if (splitEndMinutes < splitStartMinutes) {
        splitEndMinutes += 24 * 60;
      }

      totalMinutes += (splitEndMinutes - splitStartMinutes);
    }

    // Subtract rest time
    int restMinutes = int.tryParse(_restTimeController.text) ?? 0;
    totalMinutes -= restMinutes;

    // Ensure non-negative
    if (totalMinutes < 0) totalMinutes = 0;

    // Convert back to hours and minutes
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    setState(() {
      _shiftHoursController.text = hours.toString();
      _shiftMinutesController.text = minutes.toString();
    });
  }

  Future<void> _saveTemplate() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    if (_abbreviationController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) throw 'User not authenticated';

      final now = DateTime.now();

      // Determine sortOrder: preserve existing for updates, get next available for new
      int sortOrder;
      if (widget.template != null) {
        // Updating existing template - preserve sortOrder
        sortOrder = widget.template!.sortOrder;
      } else {
        // Creating new template - get count of existing templates for next sortOrder
        final existingTemplates = await ref.read(firestoreServiceProvider)
            .getUserShiftTemplates(user.uid);
        sortOrder = existingTemplates.length;
      }

      // Format schedule time as "HH:mm-HH:mm"
      final scheduleString = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}-${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

      // Format split shift times
      String? splitStart;
      String? splitEnd;
      if (_isSplitShift) {
        splitStart = '${_splitStartTime.hour.toString().padLeft(2, '0')}:${_splitStartTime.minute.toString().padLeft(2, '0')}';
        splitEnd = '${_splitEndTime.hour.toString().padLeft(2, '0')}:${_splitEndTime.minute.toString().padLeft(2, '0')}';
      }

      // Format alarm times
      String? alarm1TimeStr;
      String? alarm2TimeStr;
      if (_alarm1Enabled) {
        alarm1TimeStr = '${_alarm1Time.hour.toString().padLeft(2, '0')}:${_alarm1Time.minute.toString().padLeft(2, '0')}';
      }
      if (_alarm2Enabled) {
        alarm2TimeStr = '${_alarm2Time.hour.toString().padLeft(2, '0')}:${_alarm2Time.minute.toString().padLeft(2, '0')}';
      }

      // Parse income rates
      double? hourlyRate = double.tryParse(_perHourController.text);
      double? extraHourlyRate = double.tryParse(_perExtraHourController.text);

      final template = ShiftTemplate(
        id: widget.template?.id ?? '',
        userId: user.uid,
        name: _nameController.text.trim(),
        abbreviation: _abbreviationController.text.trim(),
        backgroundColor: _colorToHex(_backgroundColor),
        textColor: _colorToHex(_textColor),
        textSize: _textSize,
        schedule: scheduleString,
        sortOrder: sortOrder,
        createdAt: widget.template?.createdAt ?? now,
        updatedAt: now,
        isSplitShift: _isSplitShift,
        splitStartTime: splitStart,
        splitEndTime: splitEnd,
        restTimeMinutes: int.tryParse(_restTimeController.text) ?? 0,
        alarm1Enabled: _alarm1Enabled,
        alarm1Time: alarm1TimeStr,
        alarm2Enabled: _alarm2Enabled,
        alarm2Time: alarm2TimeStr,
        hourlyRate: hourlyRate,
        extraHourlyRate: extraHourlyRate,
      );

      if (widget.template == null) {
        // Creating new template
        final createTemplate = ref.read(createShiftTemplateProvider);
        await createTemplate(template);
      } else {
        // Updating existing template
        final updateTemplate = ref.read(updateShiftTemplateProvider);
        await updateTemplate(template);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Shift Configuration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Name and abbreviation inputs
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SHIFT NAME',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(color: AppColors.textDark, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Enter shift name',
                          hintStyle: TextStyle(color: AppColors.textGrey),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.textLight),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 80,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _abbreviationController.text.isEmpty
                              ? 'New'
                              : _abbreviationController.text,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: _textSize,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryTeal,
              indicatorWeight: 3,
              labelColor: AppColors.primaryTeal,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'SCHEDULE'),
                Tab(text: 'APPEARANCE'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScheduleTab(),
                _buildAppearanceTab(),
              ],
            ),
          ),

          // Bottom buttons
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: BorderSide(color: AppColors.textGrey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTemplate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Abbreviation field
          Text(
            'Abbreviation',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _abbreviationController,
            style: TextStyle(color: AppColors.textDark, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: 'Enter abbreviation',
              hintStyle: TextStyle(color: AppColors.textGrey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),

          const SizedBox(height: 24),

          // Background color
          Text(
            'Background Color',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildColorPicker(
            currentColor: _backgroundColor,
            onColorChanged: (color) => setState(() => _backgroundColor = color),
          ),

          const SizedBox(height: 24),

          // Text color
          Text(
            'Text Color',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildColorPicker(
            currentColor: _textColor,
            onColorChanged: (color) => setState(() => _textColor = color),
          ),

          const SizedBox(height: 24),

          // Text size
          Text(
            'Text Size',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _textSize.round().toString(),
                style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Slider(
                  value: _textSize,
                  min: 8,
                  max: 24,
                  divisions: 16,
                  activeColor: AppColors.primaryTeal,
                  inactiveColor: AppColors.textLight,
                  onChanged: (value) => setState(() => _textSize = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker({
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      AppColors.white,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = currentColor.value == color.value;
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.primaryTeal, width: 3)
                  : Border.all(color: AppColors.textLight, width: 1),
            ),
            child: isSelected
                ? Icon(Icons.check, color: _getBestContrastColor(color))
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SCHEDULE Section
          _buildSectionHeader('SCHEDULE'),
          const SizedBox(height: 16),
          _buildScheduleSection(),

          const SizedBox(height: 24),

          // SHIFT'S ALARMS Section
          _buildSectionHeader('SHIFT\'S ALARMS'),
          const SizedBox(height: 16),
          _buildAlarmsSection(),

          const SizedBox(height: 24),

          // INCOMES Section
          _buildSectionHeader('INCOMES'),
          const SizedBox(height: 16),
          _buildIncomesSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textDark,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Start and End Time
          Row(
            children: [
              Expanded(
                child: _buildTimeField('Start', _startTime, (time) {
                  setState(() {
                    _startTime = time;
                    _updateShiftTimeCalculation();
                  });
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '-',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: _buildTimeField('End', _endTime, (time) {
                  setState(() {
                    _endTime = time;
                    _updateShiftTimeCalculation();
                  });
                }),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Split shift checkbox
          _buildCheckboxRow(
            'Split shift',
            _isSplitShift,
            (value) {
              setState(() {
                _isSplitShift = value ?? false;
                _updateShiftTimeCalculation();
              });
            },
          ),

          // Split shift time pickers (shown when enabled)
          if (_isSplitShift) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField('Split Start', _splitStartTime, (time) {
                    setState(() {
                      _splitStartTime = time;
                      _updateShiftTimeCalculation();
                    });
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '-',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTimeField('Split End', _splitEndTime, (time) {
                    setState(() {
                      _splitEndTime = time;
                      _updateShiftTimeCalculation();
                    });
                  }),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Rest Time
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _restTimeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                    ),
                  ),
                  onChanged: (value) => _updateShiftTimeCalculation(),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Rest Time (minutes)',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calculate shift time
          Row(
            children: [
              Checkbox(
                value: _calculateShiftTime,
                onChanged: (value) {
                  setState(() {
                    _calculateShiftTime = value ?? false;
                    if (_calculateShiftTime) {
                      _updateShiftTimeCalculation();
                    }
                  });
                },
                activeColor: AppColors.primaryTeal,
              ),
              Text(
                'Calculate shift time',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _shiftHoursController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('h', style: TextStyle(color: AppColors.textDark)),
              ),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _shiftMinutesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text('m', style: TextStyle(color: AppColors.textDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return GestureDetector(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryTeal,
                  onPrimary: AppColors.white,
                  onSurface: AppColors.textDark,
                ),
              ),
              child: child!,
            );
          },
        );
        if (newTime != null) {
          onChanged(newTime);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textLight),
            ),
            child: Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryTeal,
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInputField(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDark, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.textLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.textLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Alarm 1
          _buildCheckboxRow(
            'Alarm 1',
            _alarm1Enabled,
            (value) => setState(() => _alarm1Enabled = value ?? false),
          ),
          if (_alarm1Enabled) ...[
            const SizedBox(height: 12),
            _buildTimeField('Alarm 1 Time', _alarm1Time, (time) {
              setState(() => _alarm1Time = time);
            }),
          ],
          const SizedBox(height: 16),

          // Alarm 2
          _buildCheckboxRow(
            'Alarm 2',
            _alarm2Enabled,
            (value) => setState(() => _alarm2Enabled = value ?? false),
          ),
          if (_alarm2Enabled) ...[
            const SizedBox(height: 12),
            _buildTimeField('Alarm 2 Time', _alarm2Time, (time) {
              setState(() => _alarm2Time = time);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildIncomesSection() {
    // Calculate total income based on shift hours and rates
    double totalIncome = 0.0;
    final hourlyRate = double.tryParse(_perHourController.text) ?? 0.0;
    final extraHourlyRate = double.tryParse(_perExtraHourController.text) ?? 0.0;
    final shiftHours = int.tryParse(_shiftHoursController.text) ?? 0;
    final shiftMinutes = int.tryParse(_shiftMinutesController.text) ?? 0;
    final totalHours = shiftHours + (shiftMinutes / 60);

    if (totalHours > 8) {
      // Regular 8 hours + extra hours
      totalIncome = (8 * hourlyRate) + ((totalHours - 8) * extraHourlyRate);
    } else {
      // All regular hours
      totalIncome = totalHours * hourlyRate;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Per hour rate
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _perHourController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                    ),
                  ),
                  onChanged: (value) => setState(() {}), // Trigger recalculation
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$ per hour',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Per extra hour rate
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _perExtraHourController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                    ),
                  ),
                  onChanged: (value) => setState(() {}), // Trigger recalculation
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$ per extra hour',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Total income display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryTeal),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Income:',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.primaryTeal,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return Center(
      child: Text(
        'Actions configuration\ncoming soon!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textGrey,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Get best contrast color (white or black) for a given background color
  Color _getBestContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : AppColors.white;
  }
}
