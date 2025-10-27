import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

/// Screen for managing notification preferences
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _partnerChanges = true;
  bool _conflicts = true;
  bool _freeTime = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load notification settings from Firestore
  Future<void> _loadSettings() async {
    final user = ref.read(currentFirebaseUserProvider);
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final settings = doc.data()?['notificationSettings'] as Map<String, dynamic>?;
        if (settings != null) {
          setState(() {
            _partnerChanges = settings['partnerChanges'] ?? true;
            _conflicts = settings['conflicts'] ?? true;
            _freeTime = settings['freeTime'] ?? true;
            _isLoading = false;
          });
          return;
        }
      }

      // Default settings if none exist
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Save notification settings to Firestore
  Future<void> _saveSettings() async {
    final user = ref.read(currentFirebaseUserProvider);
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'notificationSettings': {
          'partnerChanges': _partnerChanges,
          'conflicts': _conflicts,
          'freeTime': _freeTime,
        },
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    } catch (e) {
      print('Error saving notification settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notification Settings'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveSettings,
              child: const Text('SAVE'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Manage Notifications',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose what notifications you want to receive about your schedule and your partner\'s schedule.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Partner Changes Section
          Text(
            'Schedule Updates',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Partner Schedule Changes'),
                  subtitle: const Text(
                    'Get notified when your partner adds, edits, or deletes shifts',
                  ),
                  secondary: const Icon(Icons.people),
                  value: _partnerChanges,
                  onChanged: (value) {
                    setState(() {
                      _partnerChanges = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Conflicts Section
          Text(
            'Conflict Alerts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Schedule Conflicts'),
                  subtitle: const Text(
                    'Get alerted when you and your partner are both working at the same time',
                  ),
                  secondary: const Icon(Icons.warning),
                  value: _conflicts,
                  onChanged: (value) {
                    setState(() {
                      _conflicts = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Free Time Section
          Text(
            'Free Time Alerts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mutual Free Time'),
                  subtitle: const Text(
                    'Get notified when you and your partner have overlapping free time',
                  ),
                  secondary: const Icon(Icons.favorite),
                  value: _freeTime,
                  onChanged: (value) {
                    setState(() {
                      _freeTime = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save button
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Info card
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can change these settings at any time. Notifications help you stay coordinated with your partner.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
