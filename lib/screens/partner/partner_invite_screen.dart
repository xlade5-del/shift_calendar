import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';

class PartnerInviteScreen extends ConsumerStatefulWidget {
  const PartnerInviteScreen({super.key});

  @override
  ConsumerState<PartnerInviteScreen> createState() => _PartnerInviteScreenState();
}

class _PartnerInviteScreenState extends ConsumerState<PartnerInviteScreen> {
  String? _partnerCode;
  bool _isGenerating = false;
  DateTime? _expiryTime;

  Future<void> _generatePartnerCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final user = ref.read(currentFirebaseUserProvider);
      if (user == null) {
        throw 'You must be signed in to generate a partner code';
      }

      final firestoreService = ref.read(firestoreServiceProvider);
      final code = await firestoreService.generatePartnerCode(user.uid);

      setState(() {
        _partnerCode = code;
        _expiryTime = DateTime.now().add(const Duration(hours: 24));
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Partner code generated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _copyCodeToClipboard() {
    if (_partnerCode == null) return;

    Clipboard.setData(ClipboardData(text: _partnerCode!));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Partner code copied to clipboard'),
        backgroundColor: AppColors.primaryTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatExpiryTime() {
    if (_expiryTime == null) return '';

    final now = DateTime.now();
    final diff = _expiryTime!.difference(now);

    if (diff.inHours > 0) {
      return 'Expires in ${diff.inHours} hours';
    } else if (diff.inMinutes > 0) {
      return 'Expires in ${diff.inMinutes} minutes';
    } else {
      return 'Expired';
    }
  }

  @override
  Widget build(BuildContext context) {
    final partnerAsync = ref.watch(partnerDataProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Invite Partner',
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
      body: SafeArea(
        child: partnerAsync.when(
          data: (partner) {
            // User already has a partner
            if (partner != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 80,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Already Linked!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You are already linked with ${partner.displayName ?? partner.email}',
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColors.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
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

            // User doesn't have a partner yet
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Icon(
                    Icons.link,
                    size: 80,
                    color: AppColors.primaryTeal,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Invite Your Partner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generate a unique code to share with your partner. They can use this code to link their account with yours.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Partner Code Display
                  if (_partnerCode != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            'Your Partner Code',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Code Display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _partnerCode!,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Expiry Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatExpiryTime(),
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Copy Button
                          ElevatedButton.icon(
                            onPressed: _copyCodeToClipboard,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Code'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Instructions
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
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primaryTeal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Instructions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionItem('1', 'Copy the code above'),
                          _buildInstructionItem('2', 'Share it with your partner'),
                          _buildInstructionItem('3', 'They enter it in the app to link'),
                          _buildInstructionItem('4', 'Code expires in 24 hours'),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Generate Button
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generatePartnerCode,
                      icon: _isGenerating
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(Icons.add_link),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Partner Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.primaryTeal.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Card
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
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: AppColors.primaryTeal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'How It Works',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(Icons.numbers, 'Unique 6-digit code'),
                          _buildInfoItem(Icons.timer, 'Expires in 24 hours'),
                          _buildInfoItem(Icons.lock, 'Can only be used once'),
                          _buildInfoItem(Icons.sync, 'Instant synchronization'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.primaryTeal),
          ),
          error: (error, _) => Center(
            child: Text(
              'Error: $error',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
