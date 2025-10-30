import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/shift_template_provider.dart';
import '../../models/shift_template_model.dart';
import 'shift_configuration_screen.dart';

/// Bottom sheet screen showing available shift templates
class AvailableShiftsScreen extends ConsumerWidget {
  final ScrollController? scrollController;

  const AvailableShiftsScreen({super.key, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(userShiftTemplatesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.textGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section - NOT scrollable
          _buildHeader(context),

          const SizedBox(height: 16),

          // Shifts list - scrollable
          Expanded(
            child: shiftsAsync.when(
              data: (shifts) => _buildShiftsList(context, ref, shifts),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Error loading shifts: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Column(
        children: [
          // Down chevron icon
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),

          // Title
          const Text(
            'AVAILABLE SHIFTS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print('CREATE NEW SHIFT button pressed');
                      Navigator.of(context).pop(); // Close modal first
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ShiftConfigurationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CREATE NEW SHIFT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print('IMPORT SHIFTS button pressed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Import shifts feature coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'IMPORT SHIFTS...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildShiftsList(BuildContext context, WidgetRef ref, List<ShiftTemplate> shifts) {
    if (shifts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No shift templates yet.\nCreate your first shift template!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: shifts.length + 1, // +1 for bottom spacing
      itemBuilder: (context, index) {
        if (index == shifts.length) {
          return const SizedBox(height: 80);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ShiftTemplateCard(shift: shifts[index]),
        );
      },
    );
  }
}

class _ShiftTemplateCard extends ConsumerWidget {
  final ShiftTemplate shift;

  const _ShiftTemplateCard({required this.shift});

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = _parseColor(shift.backgroundColor);
    final textColor = _parseColor(shift.textColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Colored badge
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                shift.abbreviation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: shift.textSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Shift info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (shift.schedule != null && shift.schedule!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    shift.schedule!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu icon button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print('Menu button tapped for shift: ${shift.name}');
                _showOptionsMenu(context, ref);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.menu,
                  color: AppColors.textLight,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.textGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),

            // Edit option
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit', style: TextStyle(color: Colors.white)),
              onTap: () {
                print('Edit tapped for shift: ${shift.name}');
                Navigator.pop(context); // Close options menu
                Navigator.pop(context, {'action': 'edit', 'template': shift});
              },
            ),

            // Delete option
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                print('Delete tapped for shift: ${shift.name}');
                Navigator.pop(context); // Close options menu
                final confirmed = await _confirmDelete(context);
                if (confirmed) {
                  try {
                    final deleteShiftTemplate = ref.read(deleteShiftTemplateProvider);
                    await deleteShiftTemplate(shift.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${shift.name} deleted')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting shift: $e')),
                      );
                    }
                  }
                }
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shift Template'),
        content: Text('Are you sure you want to delete "${shift.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
}
