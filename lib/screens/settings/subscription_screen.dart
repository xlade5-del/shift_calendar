import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import 'legal_document_screen.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isYearlySelected = true; // Yearly is selected by default (best value)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Title
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(text: 'Find more\ntime '),
                          TextSpan(
                            text: 'together',
                            style: TextStyle(color: AppColors.primaryTeal),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Feature list
                    _buildFeatureItem(
                      icon: Icons.calendar_month,
                      text: 'Unlimited iCal feeds',
                      isHighlight: false,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.search,
                      text: 'Free time finder',
                      isHighlight: true,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.file_download_outlined,
                      text: 'PDF & iCal export',
                      isHighlight: false,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.notifications_active,
                      text: 'Advanced notifications',
                      isHighlight: false,
                    ),

                    const SizedBox(height: 40),

                    // Pricing cards
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Monthly/Yearly toggle
                          Row(
                            children: [
                              Expanded(
                                child: _buildPricingCard(
                                  title: 'Monthly',
                                  price: '\$3.99',
                                  period: '/month',
                                  isSelected: !_isYearlySelected,
                                  onTap: () => setState(() => _isYearlySelected = false),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPricingCard(
                                  title: 'Yearly',
                                  price: '\$39.99',
                                  period: '/year',
                                  discount: '-17%',
                                  isSelected: _isYearlySelected,
                                  onTap: () => setState(() => _isYearlySelected = true),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Start trial button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement subscription flow
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Subscription coming soon!'),
                                    backgroundColor: AppColors.primaryTeal,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Start 7-day trial',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Restore subscription
                          TextButton(
                            onPressed: () {
                              // TODO: Implement restore purchases
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Restore coming soon!'),
                                  backgroundColor: AppColors.primaryTeal,
                                ),
                              );
                            },
                            child: const Text(
                              'Restore subscription',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Privacy & Terms
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LegalDocumentScreen(
                                        documentType: LegalDocumentType.privacyPolicy,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Text(
                                ' · ',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LegalDocumentScreen(
                                        documentType: LegalDocumentType.termsOfService,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required bool isHighlight,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isHighlight
                ? AppColors.primaryTeal.withValues(alpha: 0.1)
                : AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isHighlight ? AppColors.primaryTeal : AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    String? discount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryTeal.withValues(alpha: 0.1)
              : AppColors.background,
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : AppColors.divider,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),
                if (discount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                if (isSelected && discount == null)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryTeal,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                children: [
                  TextSpan(text: price),
                  TextSpan(
                    text: period,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textGrey,
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
}
