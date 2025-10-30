import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';

/// Screen for managing partner relationship (view info, unlink)
class PartnerManagementScreen extends ConsumerWidget {
  const PartnerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final partnerAsync = ref.watch(partnerDataProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Partner Management',
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
      body: currentUserAsync.when(
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(
              child: Text('Error loading user data'),
            );
          }

          if (currentUser.partnerId == null) {
            return _buildNoPartnerView(context);
          }

          return partnerAsync.when(
            data: (partner) => _buildPartnerInfoView(context, ref, currentUser, partner),
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            ),
            error: (error, _) => Center(
              child: Text(
                'Error loading partner data: $error',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error loading user data: $error',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildNoPartnerView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 100,
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
              'You haven\'t linked with a partner yet.\nGo back to the home screen to invite or join a partner.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerInfoView(
    BuildContext context,
    WidgetRef ref,
    UserModel currentUser,
    UserModel? partner,
  ) {
    if (partner == null) {
      return Center(
        child: Text(
          'Partner not found',
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partner Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Partner Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryTeal.withOpacity(0.15),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Partner Name
                  Text(
                    partner.displayName ?? 'Partner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Partner Email
                  Text(
                    partner.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Linked',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Partnership Info Section
            Text(
              'Partnership Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoTile(
              context,
              Icons.sync,
              'Real-Time Sync',
              'Your calendars are synced in real-time',
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              Icons.visibility,
              'Calendar Sharing',
              'You can view each other\'s schedules',
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              Icons.notifications,
              'Change Notifications',
              'Get notified when your partner updates their schedule',
            ),
            const SizedBox(height: 32),

            // Danger Zone
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.error),
                      const SizedBox(width: 12),
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlinking will stop calendar sync and remove access to each other\'s schedules.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.error,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmUnlink(context, ref, partner),
                      icon: const Icon(Icons.link_off),
                      label: const Text('Unlink Partner'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryTeal,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmUnlink(
    BuildContext context,
    WidgetRef ref,
    UserModel partner,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Partner?'),
        content: Text(
          'Are you sure you want to unlink from ${partner.displayName ?? partner.email}?\n\n'
          'This will:\n'
          '• Stop calendar sync\n'
          '• Remove access to each other\'s schedules\n'
          '• Require a new partner code to re-link',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('UNLINK'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _unlinkPartner(context, ref);
    }
  }

  Future<void> _unlinkPartner(BuildContext context, WidgetRef ref) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      ),
    );

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentUser = ref.read(currentFirebaseUserProvider);

      if (currentUser == null) {
        throw 'User not authenticated';
      }

      await firestoreService.unlinkPartner(currentUser.uid);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Partner unlinked successfully'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back to home
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unlink partner: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
