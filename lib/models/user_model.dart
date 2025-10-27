class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? partnerId;
  final String? fcmToken;
  final DateTime? lastTokenUpdate;
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
    required this.createdAt,
    required this.updatedAt,
  });

  // Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      partnerId: null,
      fcmToken: null,
      lastTokenUpdate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
