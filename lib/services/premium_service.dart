import '../models/user_model.dart';

/// Service for managing premium subscription status
class PremiumService {
  /// Check if user has an active premium subscription
  bool checkPremiumStatus(UserModel? user) {
    if (user == null) return false;
    if (!user.isPremium) return false;

    // Check expiration if set
    if (user.premiumExpiresAt != null) {
      return DateTime.now().isBefore(user.premiumExpiresAt!);
    }

    // If no expiration date, assume lifetime premium
    return true;
  }

  /// Get days remaining until premium expires
  int? getDaysRemaining(UserModel? user) {
    if (user == null || !user.isPremium) return null;
    if (user.premiumExpiresAt == null) return null; // Lifetime

    final now = DateTime.now();
    if (now.isAfter(user.premiumExpiresAt!)) return 0;

    return user.premiumExpiresAt!.difference(now).inDays;
  }

  /// Check if premium is expiring soon (within 7 days)
  bool isExpiringSoon(UserModel? user) {
    final daysRemaining = getDaysRemaining(user);
    if (daysRemaining == null) return false;
    return daysRemaining <= 7 && daysRemaining > 0;
  }
}
