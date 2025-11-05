import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a workplace/calendar that a user can manage
class WorkplaceModel {
  final String workplaceId;
  final String userId;
  final String name;
  final int order; // Display order (0-4 for up to 5 workplaces)
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkplaceModel({
    required this.workplaceId,
    required this.userId,
    required this.name,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create WorkplaceModel from Firestore document
  factory WorkplaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkplaceModel(
      workplaceId: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      order: data['order'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert WorkplaceModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields
  WorkplaceModel copyWith({
    String? workplaceId,
    String? userId,
    String? name,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkplaceModel(
      workplaceId: workplaceId ?? this.workplaceId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkplaceModel(workplaceId: $workplaceId, userId: $userId, name: $name, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkplaceModel && other.workplaceId == workplaceId;
  }

  @override
  int get hashCode => workplaceId.hashCode;
}
