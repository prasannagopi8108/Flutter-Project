import 'package:flutter/material.dart';

/// Strongly typed domain model representing a scheduled medicine dose.
@immutable
class Medicine {
  /// Unique identifier for the medicine reminder.
  final String id;

  /// Name of the medication (e.g. 'Amoxicillin', 'Vitamin D').
  final String medicineName;

  /// Quantity or dose strength (e.g. '500 mg', '1 tablet').
  final String dosage;

  /// Intake instructions (e.g. 'Take after breakfast with a full glass of water').
  final String instructions;

  /// User-facing scheduled time string (e.g. '08:00 AM').
  final String scheduledTime;

  /// Optional start date of the medication course.
  final DateTime? startDate;

  /// Optional end date of the medication course.
  final DateTime? endDate;

  /// Whether the scheduled dose has been taken today.
  final bool isTaken;

  /// 32-bit ARGB representation of card accent color.
  final int colorValue;

  /// Code point of the icon used to visually identify the medication.
  final int iconCodePoint;

  /// Timestamp when this reminder was created.
  final DateTime createdAt;

  /// Timestamp when this reminder was last edited.
  final DateTime? updatedAt;

  const Medicine({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.instructions,
    required this.scheduledTime,
    this.startDate,
    this.endDate,
    this.isTaken = false,
    this.colorValue = 0xFF00796B, // Default medical teal
    this.iconCodePoint = 0xe3d9, // Default Icons.medication_outlined codepoint
    required this.createdAt,
    this.updatedAt,
  });

  /// Convenience getter returning the Flutter [Color] from [colorValue].
  Color get color => Color(colorValue);

  /// Convenience getter returning the Flutter [IconData] from [iconCodePoint].
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Creates a copy of this [Medicine] instance with selectively replaced values.
  Medicine copyWith({
    String? id,
    String? medicineName,
    String? dosage,
    String? instructions,
    String? scheduledTime,
    DateTime? startDate,
    DateTime? endDate,
    bool? isTaken,
    int? colorValue,
    int? iconCodePoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isTaken: isTaken ?? this.isTaken,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the [Medicine] object to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'medicineName': medicineName,
      'dosage': dosage,
      'instructions': instructions,
      'scheduledTime': scheduledTime,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isTaken': isTaken,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Safely parses a [Medicine] object from a map, handling missing or corrupted keys.
  factory Medicine.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    DateTime? parseOptionalDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    final now = DateTime.now();

    return Medicine(
      id: map['id']?.toString() ?? UniqueKey().toString(),
      medicineName: map['medicineName']?.toString() ?? 'Unnamed Medicine',
      dosage: map['dosage']?.toString() ?? '1 dose',
      instructions: map['instructions']?.toString() ?? '',
      scheduledTime: map['scheduledTime']?.toString() ?? '08:00 AM',
      startDate: parseOptionalDate(map['startDate']),
      endDate: parseOptionalDate(map['endDate']),
      isTaken: map['isTaken'] == true,
      colorValue: (map['colorValue'] is int)
          ? map['colorValue'] as int
          : 0xFF00796B,
      iconCodePoint: (map['iconCodePoint'] is int)
          ? map['iconCodePoint'] as int
          : 0xe3d9,
      createdAt: parseDate(map['createdAt'], now),
      updatedAt: parseOptionalDate(map['updatedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Medicine &&
        other.id == id &&
        other.medicineName == medicineName &&
        other.dosage == dosage &&
        other.instructions == instructions &&
        other.scheduledTime == scheduledTime &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isTaken == isTaken &&
        other.colorValue == colorValue &&
        other.iconCodePoint == iconCodePoint;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      medicineName,
      dosage,
      instructions,
      scheduledTime,
      startDate,
      endDate,
      isTaken,
      colorValue,
      iconCodePoint,
    );
  }
}
