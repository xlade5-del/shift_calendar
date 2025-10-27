import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

/// Screen for managing partner relationship (view info, unlink)
class PartnerManagementScreen extends ConsumerWidget {
  const PartnerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final partnerAsync = ref.watch(partnerDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Management'),
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error loading partner data: $error',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error loading user data: $error',
            style: TextStyle(color: Colors.red[700]),
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
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Partner Linked',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t linked with a partner yet.\nGo back to the home screen to invite or join a partner.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
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
      return const Center(
        child: Text('Partner not found'),
      );
    }

    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partner Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Partner Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Partner Name
                    Text(
                      partner.displayName ?? 'Partner',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Partner Email
                    Text(
                      partner.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
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
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Linked',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Partnership Info Section
            Text(
              'Partnership Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Text(
                        'Danger Zone',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlinking will stop calendar sync and remove access to each other\'s schedules.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
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
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
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
          const SnackBar(
            content: Text('Partner unlinked successfully'),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
