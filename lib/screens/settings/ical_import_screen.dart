import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';

/// Screen for managing iCal feed imports
class IcalImportScreen extends ConsumerStatefulWidget {
  const IcalImportScreen({super.key});

  @override
  ConsumerState<IcalImportScreen> createState() => _IcalImportScreenState();
}

class _IcalImportScreenState extends ConsumerState<IcalImportScreen> {
  List<IcalFeedModel> _feeds = [];
  bool _isLoading = true;
  bool _isSaving = false;
  final TextEditingController _urlController = TextEditingController();
  String? _urlError;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Load iCal feeds from Firestore
  Future<void> _loadFeeds() async {
    final user = ref.read(currentFirebaseUserProvider);
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data();
        final feedsList = data?['icalFeeds'] as List?;
        if (feedsList != null) {
          setState(() {
            _feeds = feedsList
                .map((feed) => IcalFeedModel.fromMap(feed as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
          return;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading iCal feeds: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Validate HTTPS URL
  bool _validateUrl(String url) {
    if (url.isEmpty) {
      setState(() {
        _urlError = 'Please enter a URL';
      });
      return false;
    }

    if (!url.startsWith('https://')) {
      setState(() {
        _urlError = 'URL must start with https://';
      });
      return false;
    }

    // Basic URL validation
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      setState(() {
        _urlError = 'Please enter a valid URL';
      });
      return false;
    }

    // Check for .ics extension or common calendar providers
    if (!url.endsWith('.ics') &&
        !url.contains('calendar.google.com') &&
        !url.contains('outlook.live.com') &&
        !url.contains('icloud.com')) {
      setState(() {
        _urlError = 'URL should be an iCal feed (.ics) or from a supported provider';
      });
      return false;
    }

    setState(() {
      _urlError = null;
    });
    return true;
  }

  /// Add new iCal feed
  Future<void> _addFeed() async {
    final url = _urlController.text.trim();

    if (!_validateUrl(url)) return;

    // Check for duplicates
    if (_feeds.any((feed) => feed.url == url)) {
      setState(() {
        _urlError = 'This feed is already added';
      });
      return;
    }

    final user = ref.read(currentFirebaseUserProvider);
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final newFeed = IcalFeedModel(url: url);
      final updatedFeeds = [..._feeds, newFeed];

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'icalFeeds': updatedFeeds.map((feed) => feed.toMap()).toList(),
      });

      setState(() {
        _feeds = updatedFeeds;
        _urlController.clear();
        _urlError = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('iCal feed added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      // Close the add dialog
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding iCal feed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding feed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
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

  /// Delete iCal feed
  Future<void> _deleteFeed(IcalFeedModel feed) async {
    final user = ref.read(currentFirebaseUserProvider);
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedFeeds = _feeds.where((f) => f.url != feed.url).toList();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'icalFeeds': updatedFeeds.map((feed) => feed.toMap()).toList(),
      });

      setState(() {
        _feeds = updatedFeeds;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('iCal feed removed'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('Error deleting iCal feed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing feed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
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

  /// Show add feed dialog
  void _showAddFeedDialog() {
    _urlController.clear();
    setState(() {
      _urlError = null;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Add iCal Feed',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the HTTPS URL of your iCal feed (e.g., Google Calendar, Outlook, or .ics file)',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://calendar.google.com/...',
                hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.6)),
                errorText: _urlError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.error, width: 1),
                ),
              ),
              maxLines: 3,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _addFeed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Add Feed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'iCal Import',
            style: TextStyle(color: AppColors.textDark),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'iCal Import',
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header card
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryTeal,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Calendar Imports',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Import shifts from external calendars like Google Calendar, Outlook, or iCloud. Cloud Functions will sync your feeds every 15 minutes.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add feed button
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _showAddFeedDialog,
            icon: Icon(Icons.add, color: AppColors.white),
            label: Text(
              'Add iCal Feed',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 24),

          // Feeds list
          if (_feeds.isEmpty)
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 64,
                    color: AppColors.textGrey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No iCal Feeds',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add an iCal feed to automatically import shifts from your external calendars.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textGrey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._feeds.map((feed) => _buildFeedCard(feed)).toList(),

          const SizedBox(height: 24),

          // Info card
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryTeal,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Free tier: 1 iCal feed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cloud Functions sync feeds every 15 minutes. Upgrade to premium for unlimited feeds and faster sync.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Build feed card widget
  Widget _buildFeedCard(IcalFeedModel feed) {
    final lastSyncText = feed.lastSync != null
        ? DateFormat('MMM d, y h:mm a').format(feed.lastSync!)
        : 'Not synced yet';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feed header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  color: AppColors.primaryTeal,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFeedDisplayName(feed.url),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feed.url.length > 50
                            ? '${feed.url.substring(0, 50)}...'
                            : feed.url,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _confirmDeleteFeed(feed),
                ),
              ],
            ),
          ),

          // Divider
          Divider(color: AppColors.textGrey.withOpacity(0.2), height: 1),

          // Feed details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sync,
                      color: AppColors.textGrey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last sync:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lastSyncText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.textGrey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sync interval:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${feed.syncInterval} minutes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get display name from URL
  String _getFeedDisplayName(String url) {
    if (url.contains('calendar.google.com')) {
      return 'Google Calendar';
    } else if (url.contains('outlook.live.com') || url.contains('outlook.office365.com')) {
      return 'Outlook Calendar';
    } else if (url.contains('icloud.com')) {
      return 'iCloud Calendar';
    } else {
      return 'iCal Feed';
    }
  }

  /// Confirm delete feed
  void _confirmDeleteFeed(IcalFeedModel feed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Remove iCal Feed?',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will stop importing shifts from this calendar. Existing imported shifts will not be deleted.',
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFeed(feed);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
