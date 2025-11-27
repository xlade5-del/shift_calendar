import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/premium_service.dart';
import 'auth_provider.dart';

/// Provider for PremiumService singleton
final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService();
});

/// Provider to check if current user has premium
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(currentUserDataProvider.future);
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.checkPremiumStatus(user);
});

/// Provider to get days remaining until premium expires
final premiumDaysRemainingProvider = FutureProvider<int?>((ref) async {
  final user = await ref.watch(currentUserDataProvider.future);
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.getDaysRemaining(user);
});

/// Provider to check if premium is expiring soon
final isPremiumExpiringSoonProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(currentUserDataProvider.future);
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.isExpiringSoon(user);
});
