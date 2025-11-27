import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/premium_provider.dart';
import '../services/export_service.dart';
import '../utils/app_colors.dart';
import 'premium_upgrade_dialog.dart';

enum ExportPeriod { month, year }

class ShareOptionsDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const ShareOptionsDialog({
    super.key,
    required this.selectedDate,
  });

  @override
  ConsumerState<ShareOptionsDialog> createState() => _ShareOptionsDialogState();
}

class _ShareOptionsDialogState extends ConsumerState<ShareOptionsDialog> {
  ExportPeriod _icalPeriod = ExportPeriod.month;
  ExportPeriod _pdfPeriod = ExportPeriod.month;
  bool _isLoading = false;

  final _exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Share Calendar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Text Summary Option (FREE)
              _buildShareOption(
                icon: Icons.text_snippet,
                iconColor: AppColors.primaryTeal,
                title: 'Text Summary',
                subtitle: 'Share as plain text',
                isFree: true,
                isLocked: false,
                onTap: _isLoading ? null : _handleTextShare,
              ),

              const SizedBox(height: 16),

              // iCal Export Option (PREMIUM)
              isPremiumAsync.when(
                data: (isPremium) => _buildShareOption(
                  icon: Icons.calendar_month,
                  iconColor: AppColors.primaryTeal,
                  title: 'iCal Export',
                  subtitle: 'Share as .ics file',
                  isFree: false,
                  isLocked: !isPremium,
                  onTap: _isLoading
                      ? null
                      : () => _handleIcalExport(isPremium),
                  periodSelector: isPremium
                      ? _buildPeriodSelector(
                          _icalPeriod,
                          (period) => setState(() => _icalPeriod = period),
                        )
                      : null,
                ),
                loading: () => _buildShareOption(
                  icon: Icons.calendar_month,
                  iconColor: AppColors.primaryTeal,
                  title: 'iCal Export',
                  subtitle: 'Loading...',
                  isFree: false,
                  isLocked: true,
                  onTap: null,
                ),
                error: (_, __) => _buildShareOption(
                  icon: Icons.calendar_month,
                  iconColor: AppColors.primaryTeal,
                  title: 'iCal Export',
                  subtitle: 'Share as .ics file',
                  isFree: false,
                  isLocked: true,
                  onTap: null,
                ),
              ),

              const SizedBox(height: 16),

              // PDF Export Option (PREMIUM)
              isPremiumAsync.when(
                data: (isPremium) => _buildShareOption(
                  icon: Icons.picture_as_pdf,
                  iconColor: AppColors.primaryTeal,
                  title: 'PDF Export',
                  subtitle: 'Share as PDF document',
                  isFree: false,
                  isLocked: !isPremium,
                  onTap: _isLoading ? null : () => _handlePdfExport(isPremium),
                  periodSelector: isPremium
                      ? _buildPeriodSelector(
                          _pdfPeriod,
                          (period) => setState(() => _pdfPeriod = period),
                        )
                      : null,
                ),
                loading: () => _buildShareOption(
                  icon: Icons.picture_as_pdf,
                  iconColor: AppColors.primaryTeal,
                  title: 'PDF Export',
                  subtitle: 'Loading...',
                  isFree: false,
                  isLocked: true,
                  onTap: null,
                ),
                error: (_, __) => _buildShareOption(
                  icon: Icons.picture_as_pdf,
                  iconColor: AppColors.primaryTeal,
                  title: 'PDF Export',
                  subtitle: 'Share as PDF document',
                  isFree: false,
                  isLocked: true,
                  onTap: null,
                ),
              ),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isFree,
    required bool isLocked,
    required VoidCallback? onTap,
    Widget? periodSelector,
  }) {
    return InkWell(
      onTap: isLocked
          ? () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const PremiumUpgradeDialog(),
              );
            }
          : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked ? AppColors.shadowLight : AppColors.primaryTeal.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isLocked)
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: AppColors.warning,
                            ),
                        ],
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isFree)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            if (periodSelector != null) ...[
              const SizedBox(height: 12),
              periodSelector,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(
    ExportPeriod selectedPeriod,
    ValueChanged<ExportPeriod> onChanged,
  ) {
    return Row(
      children: [
        const SizedBox(width: 52), // Align with text
        Expanded(
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Month'),
                selected: selectedPeriod == ExportPeriod.month,
                onSelected: (_) => onChanged(ExportPeriod.month),
                selectedColor: AppColors.primaryTeal,
                labelStyle: TextStyle(
                  color: selectedPeriod == ExportPeriod.month
                      ? AppColors.white
                      : AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Year'),
                selected: selectedPeriod == ExportPeriod.year,
                onSelected: (_) => onChanged(ExportPeriod.year),
                selectedColor: AppColors.primaryTeal,
                labelStyle: TextStyle(
                  color: selectedPeriod == ExportPeriod.year
                      ? AppColors.white
                      : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleTextShare() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      final user = await ref.read(currentUserDataProvider.future);
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Fetch events for the month
      final monthStart = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
      final events = await ref.read(monthEventsStreamProvider(monthStart).future);

      if (events.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No events to export for this period'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Generate text summary
      final summary = _exportService.generateTextSummary(
        events,
        monthStart,
        user.displayName ?? 'My',
      );

      // Share
      final monthName = DateFormat('MMMM yyyy').format(monthStart);
      await Share.share(
        summary,
        subject: 'Schedule for $monthName',
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleIcalExport(bool isPremium) async {
    if (!isPremium) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => const PremiumUpgradeDialog(),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user
      final user = await ref.read(currentUserDataProvider.future);
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Determine date range
      final DateTime startDate;

      if (_icalPeriod == ExportPeriod.month) {
        startDate = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
      } else {
        startDate = DateTime(widget.selectedDate.year, 1, 1);
      }

      // Fetch events
      final provider = _icalPeriod == ExportPeriod.month
          ? monthEventsStreamProvider(startDate)
          : yearEventsStreamProvider(startDate);

      final events = await ref.read(provider.future);

      if (events.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No events to export for this period'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Generate iCal file
      final filePath = await _exportService.generateIcalFile(
        events,
        user.uid,
        calendarName: 'VelloShift Calendar',
      );

      // Share file
      await Share.shareXFiles([XFile(filePath)]);

      // Cleanup after delay
      Future.delayed(const Duration(seconds: 5), () async {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Non-critical error, ignore
        }
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePdfExport(bool isPremium) async {
    if (!isPremium) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => const PremiumUpgradeDialog(),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user
      final user = await ref.read(currentUserDataProvider.future);
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Determine date range
      final DateTime startDate;
      final DateTime endDate;
      final bool isYearView;

      if (_pdfPeriod == ExportPeriod.month) {
        startDate = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
        endDate = DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0);
        isYearView = false;
      } else {
        startDate = DateTime(widget.selectedDate.year, 1, 1);
        endDate = DateTime(widget.selectedDate.year, 12, 31);
        isYearView = true;
      }

      // Fetch events
      final provider = _pdfPeriod == ExportPeriod.month
          ? monthEventsStreamProvider(startDate)
          : yearEventsStreamProvider(startDate);

      final events = await ref.read(provider.future);

      if (events.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No events to export for this period'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Generate PDF
      final filePath = await _exportService.generatePdfFile(
        events,
        startDate,
        endDate,
        isYearView: isYearView,
      );

      // Share file
      await Share.shareXFiles([XFile(filePath)]);

      // Cleanup after delay
      Future.delayed(const Duration(seconds: 5), () async {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Non-critical error, ignore
        }
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
