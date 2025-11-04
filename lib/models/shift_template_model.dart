import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftTemplate {
  final String id;
  final String userId;
  final String name;
  final String abbreviation;
  final String backgroundColor; // Hex color string
  final String textColor; // Hex color string
  final double textSize;
  final String? schedule; // Optional schedule info (e.g., "14:30-21:00")
  final int sortOrder; // Order for displaying shifts (lower = first)
  final DateTime createdAt;
  final DateTime updatedAt;

  ShiftTemplate({
    required this.id,
    required this.userId,
    required this.name,
    required this.abbreviation,
    required this.backgroundColor,
    required this.textColor,
    required this.textSize,
    this.schedule,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create ShiftTemplate from Firestore document
  factory ShiftTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShiftTemplate(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      abbreviation: data['abbreviation'] as String,
      backgroundColor: data['backgroundColor'] as String,
      textColor: data['textColor'] as String,
      textSize: (data['textSize'] as num).toDouble(),
      schedule: data['schedule'] as String?,
      sortOrder: (data['sortOrder'] as int?) ?? 0, // Default to 0 for backwards compatibility
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert ShiftTemplate to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'abbreviation': abbreviation,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'textSize': textSize,
      'schedule': schedule,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // CopyWith method for creating modified copies
  ShiftTemplate copyWith({
    String? id,
    String? userId,
    String? name,
    String? abbreviation,
    String? backgroundColor,
    String? textColor,
    double? textSize,
    String? schedule,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftTemplate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      textSize: textSize ?? this.textSize,
      schedule: schedule ?? this.schedule,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
