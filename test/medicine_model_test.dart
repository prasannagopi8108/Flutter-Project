import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/models/medicine.dart';

void main() {
  group('Medicine Model Tests', () {
    test('Correctly serializes to Map and deserializes from Map', () {
      final now = DateTime(2026, 10, 26, 8, 30);
      final medicine = Medicine(
        id: 'test-123',
        medicineName: 'Paracetamol',
        dosage: '500 mg',
        instructions: 'Take after meals',
        scheduledTime: '08:00 AM',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        isTaken: true,
        colorValue: 0xFF00796B,
        iconCodePoint: Icons.medication_outlined.codePoint,
        createdAt: now,
      );

      final map = medicine.toMap();
      final reconstituted = Medicine.fromMap(map);

      expect(reconstituted.id, 'test-123');
      expect(reconstituted.medicineName, 'Paracetamol');
      expect(reconstituted.dosage, '500 mg');
      expect(reconstituted.instructions, 'Take after meals');
      expect(reconstituted.scheduledTime, '08:00 AM');
      expect(reconstituted.isTaken, isTrue);
      expect(reconstituted.colorValue, 0xFF00796B);
      expect(reconstituted.iconCodePoint, Icons.medication_outlined.codePoint);
    });

    test('Gracefully handles missing or corrupted keys with safe fallbacks', () {
      final corruptedMap = <String, dynamic>{
        'id': null,
        'medicineName': null,
        'dosage': null,
        'scheduledTime': null,
        'isTaken': 'invalid_boolean',
        'colorValue': 'not_an_int',
      };

      final parsed = Medicine.fromMap(corruptedMap);

      expect(parsed.medicineName, 'Unnamed Medicine');
      expect(parsed.dosage, '1 dose');
      expect(parsed.scheduledTime, '08:00 AM');
      expect(parsed.isTaken, isFalse);
      expect(parsed.colorValue, 0xFF00796B);
    });

    test('copyWith properly overrides selected fields while preserving unchanged values', () {
      final original = Medicine(
        id: '1',
        medicineName: 'Aspirin',
        dosage: '100 mg',
        instructions: 'Morning',
        scheduledTime: '07:00 AM',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        isTaken: true,
        dosage: '200 mg',
      );

      expect(updated.id, original.id);
      expect(updated.medicineName, 'Aspirin');
      expect(updated.dosage, '200 mg');
      expect(updated.instructions, original.instructions);
      expect(updated.scheduledTime, '07:00 AM');
      expect(updated.isTaken, isTrue);
    });

    test('Equality operator and hashCode test', () {
      final now = DateTime(2026, 10, 26, 8, 0);
      final medA = Medicine(
        id: 'same-id',
        medicineName: 'A',
        dosage: '1',
        instructions: 'none',
        scheduledTime: '08:00 AM',
        createdAt: now,
      );

      final medB = Medicine(
        id: 'same-id',
        medicineName: 'A',
        dosage: '1',
        instructions: 'none',
        scheduledTime: '08:00 AM',
        createdAt: now,
      );

      expect(medA, equals(medB));
      expect(medA.hashCode, equals(medB.hashCode));
    });
  });
}
