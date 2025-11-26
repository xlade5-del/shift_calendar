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

  // Split shift fields
  final bool isSplitShift;
  final String? splitStartTime; // Second part start time (e.g., "18:00")
  final String? splitEndTime; // Second part end time (e.g., "22:00")

  // Rest time
  final int restTimeMinutes;

  // Alarms
  final bool alarm1Enabled;
  final String? alarm1Time; // Time of alarm (e.g., "06:00")
  final bool alarm2Enabled;
  final String? alarm2Time; // Time of alarm (e.g., "07:00")

  // Income
  final double? hourlyRate;
  final double? extraHourlyRate;

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
    this.isSplitShift = false,
    this.splitStartTime,
    this.splitEndTime,
    this.restTimeMinutes = 0,
    this.alarm1Enabled = false,
    this.alarm1Time,
    this.alarm2Enabled = false,
    this.alarm2Time,
    this.hourlyRate,
    this.extraHourlyRate,
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
      sortOrder: (data['sortOrder'] as int?) ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isSplitShift: (data['isSplitShift'] as bool?) ?? false,
      splitStartTime: data['splitStartTime'] as String?,
      splitEndTime: data['splitEndTime'] as String?,
      restTimeMinutes: (data['restTimeMinutes'] as int?) ?? 0,
      alarm1Enabled: (data['alarm1Enabled'] as bool?) ?? false,
      alarm1Time: data['alarm1Time'] as String?,
      alarm2Enabled: (data['alarm2Enabled'] as bool?) ?? false,
      alarm2Time: data['alarm2Time'] as String?,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble(),
      extraHourlyRate: (data['extraHourlyRate'] as num?)?.toDouble(),
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
      'isSplitShift': isSplitShift,
      'splitStartTime': splitStartTime,
      'splitEndTime': splitEndTime,
      'restTimeMinutes': restTimeMinutes,
      'alarm1Enabled': alarm1Enabled,
      'alarm1Time': alarm1Time,
      'alarm2Enabled': alarm2Enabled,
      'alarm2Time': alarm2Time,
      'hourlyRate': hourlyRate,
      'extraHourlyRate': extraHourlyRate,
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
    bool? isSplitShift,
    String? splitStartTime,
    String? splitEndTime,
    int? restTimeMinutes,
    bool? alarm1Enabled,
    String? alarm1Time,
    bool? alarm2Enabled,
    String? alarm2Time,
    double? hourlyRate,
    double? extraHourlyRate,
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
      isSplitShift: isSplitShift ?? this.isSplitShift,
      splitStartTime: splitStartTime ?? this.splitStartTime,
      splitEndTime: splitEndTime ?? this.splitEndTime,
      restTimeMinutes: restTimeMinutes ?? this.restTimeMinutes,
      alarm1Enabled: alarm1Enabled ?? this.alarm1Enabled,
      alarm1Time: alarm1Time ?? this.alarm1Time,
      alarm2Enabled: alarm2Enabled ?? this.alarm2Enabled,
      alarm2Time: alarm2Time ?? this.alarm2Time,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      extraHourlyRate: extraHourlyRate ?? this.extraHourlyRate,
    );
  }
}
