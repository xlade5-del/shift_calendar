import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';

/// Screen to display legal documents (Privacy Policy, Terms of Service)
class LegalDocumentScreen extends StatefulWidget {
  final LegalDocumentType documentType;

  const LegalDocumentScreen({
    super.key,
    required this.documentType,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  /// Load the legal document content
  Future<void> _loadDocument() async {
    try {
      String content;
      switch (widget.documentType) {
        case LegalDocumentType.privacyPolicy:
          content = await rootBundle.loadString('assets/legal/privacy_policy.txt');
          break;
        case LegalDocumentType.termsOfService:
          content = await rootBundle.loadString('assets/legal/terms_of_service.txt');
          break;
      }

      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading legal document: $e');
      if (mounted) {
        setState(() {
          _content = 'Error loading document. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        shadowColor: AppColors.shadowLight,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryTeal,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document header
                    Text(
                      _getTitle(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Updated: November 8, 2025',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Document content
                    SelectableText(
                      _content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Contact info at bottom
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cream.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Questions?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Contact us at support@velloshift.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.documentType == LegalDocumentType.privacyPolicy
                                ? 'For privacy requests, use subject "Privacy Rights Request"'
                                : 'For legal notices, use subject "Legal Notice"',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getTitle() {
    switch (widget.documentType) {
      case LegalDocumentType.privacyPolicy:
        return 'Privacy Policy';
      case LegalDocumentType.termsOfService:
        return 'Terms of Service';
    }
  }
}

/// Legal document types
enum LegalDocumentType {
  privacyPolicy,
  termsOfService,
}
