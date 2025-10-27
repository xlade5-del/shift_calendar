import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'partner/partner_invite_screen.dart';
import 'partner/partner_accept_screen.dart';
import 'partner/partner_management_screen.dart';
import 'calendar/calendar_screen.dart';
import 'settings/notification_settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final user = ref.watch(currentFirebaseUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deb ShiftSync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
            tooltip: 'Notification Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
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
                    FilledButton(
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
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              const SizedBox(height: 24),

              // Welcome Message
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // User Info
              userAsync.when(
                data: (userData) {
                  return Column(
                    children: [
                      Text(
                        userData?.displayName ?? user?.displayName ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData?.email ?? user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text(
                  'Error loading user data',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
              const SizedBox(height: 48),

              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authentication Working!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Week 3-4 milestone completed.\nNext: Partner linking & Calendar UI',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Partner Section
                      const Divider(),
                      const SizedBox(height: 16),
                      // Re-watch user data for partner status
                      ...userAsync.when(
                        data: (currentUserData) => [
                          Text(
                            currentUserData?.partnerId != null ? 'Partner:' : 'Partner Linking:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          // Show different content based on partner status
                          if (currentUserData?.partnerId != null)
                        // Manage Partner Button (when partner is linked)
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PartnerManagementScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.manage_accounts),
                          label: const Text('Manage Partner'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )
                      else ...[
                        // Invite Partner Button
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PartnerInviteScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Invite Partner'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Accept Invite Button
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                          ],
                        ],
                        loading: () => [const CircularProgressIndicator()],
                        error: (_, __) => [const SizedBox.shrink()],
                      ),
                      const SizedBox(height: 24),

                      // Calendar Section
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Calendar:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // View Calendar Button
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CalendarScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('View Calendar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Coming Soon Features
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Coming Soon:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context,
                        Icons.sync,
                        'Real-time Sync',
                        'Instant updates across devices',
                      ),
                      _buildFeatureItem(
                        context,
                        Icons.event_note,
                        'Manual Event Creation',
                        'Add your own shifts manually',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
}
