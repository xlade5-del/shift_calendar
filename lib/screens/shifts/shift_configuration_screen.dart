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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize with existing template data if editing
    if (widget.template != null) {
      _nameController = TextEditingController(text: widget.template!.name);
      _abbreviationController = TextEditingController(text: widget.template!.abbreviation);
      _backgroundColor = _parseColor(widget.template!.backgroundColor);
      _textColor = _parseColor(widget.template!.textColor);
      _textSize = widget.template!.textSize;
    } else {
      _nameController = TextEditingController(text: 'New');
      _abbreviationController = TextEditingController(text: 'New');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _abbreviationController.dispose();
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

  Future<void> _saveTemplate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shift name')),
      );
      return;
    }

    if (_abbreviationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an abbreviation')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) throw 'User not authenticated';

      final now = DateTime.now();
      final template = ShiftTemplate(
        id: widget.template?.id ?? '',
        userId: user.uid,
        name: _nameController.text.trim(),
        abbreviation: _abbreviationController.text.trim(),
        backgroundColor: _colorToHex(_backgroundColor),
        textColor: _colorToHex(_textColor),
        textSize: _textSize,
        schedule: null, // TODO: Implement schedule tab
        createdAt: widget.template?.createdAt ?? now,
        updatedAt: now,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.template == null
                ? 'Shift template created!'
                : 'Shift template updated!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving template: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
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
                  'Shift name',
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
                          fillColor: AppColors.cream,
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
                Tab(text: 'Appearance'),
                Tab(text: 'Schedule'),
                Tab(text: 'Actions'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppearanceTab(),
                _buildScheduleTab(),
                _buildActionsTab(),
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
      Colors.white,
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
    return Center(
      child: Text(
        'Schedule configuration\ncoming soon!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textGrey,
          fontSize: 16,
        ),
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
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
