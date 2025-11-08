/// Model representing an iCal feed subscription
class IcalFeedModel {
  final String url;
  final DateTime? lastSync;
  final int syncInterval; // in minutes, default 15

  const IcalFeedModel({
    required this.url,
    this.lastSync,
    this.syncInterval = 15,
  });

  factory IcalFeedModel.fromMap(Map<String, dynamic> map) {
    return IcalFeedModel(
      url: map['url'] ?? '',
      lastSync: map['lastSync'] != null
          ? (map['lastSync'] as dynamic).toDate()
          : null,
      syncInterval: map['syncInterval'] ?? 15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'lastSync': lastSync,
      'syncInterval': syncInterval,
    };
  }
}

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? partnerId;
  final String? fcmToken;
  final DateTime? lastTokenUpdate;
  final List<IcalFeedModel> icalFeeds;
  final DateTime? privacyPolicyAcceptedAt;
  final DateTime? termsOfServiceAcceptedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.partnerId,
    this.fcmToken,
    this.lastTokenUpdate,
    this.icalFeeds = const [],
    this.privacyPolicyAcceptedAt,
    this.termsOfServiceAcceptedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    final now = DateTime.now();
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      partnerId: null,
      fcmToken: null,
      lastTokenUpdate: null,
      privacyPolicyAcceptedAt: now, // Set to now when creating account
      termsOfServiceAcceptedAt: now, // Set to now when creating account
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['name'],
      photoUrl: map['photoUrl'],
      partnerId: map['partnerId'],
      fcmToken: map['fcmToken'],
      lastTokenUpdate: map['lastTokenUpdate'] != null
          ? (map['lastTokenUpdate'] as dynamic).toDate()
          : null,
      icalFeeds: map['icalFeeds'] != null
          ? (map['icalFeeds'] as List)
              .map((feed) => IcalFeedModel.fromMap(feed as Map<String, dynamic>))
              .toList()
          : [],
      privacyPolicyAcceptedAt: map['privacyPolicyAcceptedAt'] != null
          ? (map['privacyPolicyAcceptedAt'] as dynamic).toDate()
          : null,
      termsOfServiceAcceptedAt: map['termsOfServiceAcceptedAt'] != null
          ? (map['termsOfServiceAcceptedAt'] as dynamic).toDate()
          : null,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      updatedAt: (map['updatedAt'] as dynamic).toDate(),
    );
  }

  // Convert UserModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': displayName,
      'photoUrl': photoUrl,
      'partnerId': partnerId,
      'fcmToken': fcmToken,
      'lastTokenUpdate': lastTokenUpdate,
      'icalFeeds': icalFeeds.map((feed) => feed.toMap()).toList(),
      'privacyPolicyAcceptedAt': privacyPolicyAcceptedAt,
      'termsOfServiceAcceptedAt': termsOfServiceAcceptedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? partnerId,
    String? fcmToken,
    DateTime? lastTokenUpdate,
    List<IcalFeedModel>? icalFeeds,
    DateTime? privacyPolicyAcceptedAt,
    DateTime? termsOfServiceAcceptedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      partnerId: partnerId ?? this.partnerId,
      fcmToken: fcmToken ?? this.fcmToken,
      lastTokenUpdate: lastTokenUpdate ?? this.lastTokenUpdate,
      icalFeeds: icalFeeds ?? this.icalFeeds,
      privacyPolicyAcceptedAt: privacyPolicyAcceptedAt ?? this.privacyPolicyAcceptedAt,
      termsOfServiceAcceptedAt: termsOfServiceAcceptedAt ?? this.termsOfServiceAcceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
