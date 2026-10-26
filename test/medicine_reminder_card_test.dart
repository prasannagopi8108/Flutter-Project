import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/widgets/medicine_reminder_card.dart';

void main() {
  group('MedicineReminderCard Widget Tests', () {
    testWidgets('Renders all medication details correctly in pending state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicineReminderCard(
              medicineName: 'Vitamin D3',
              dosage: '1 tablet (1000 IU)',
              instructions: 'Take after breakfast',
              scheduledTime: '09:00 AM',
              isTaken: false,
            ),
          ),
        ),
      );

      expect(find.text('Vitamin D3'), findsOneWidget);
      expect(find.text('1 tablet (1000 IU)'), findsOneWidget);
      expect(find.text('Take after breakfast'), findsOneWidget);
      expect(find.text('09:00 AM'), findsOneWidget);
      expect(find.text('Mark Taken'), findsOneWidget);
    });

    testWidgets('Renders completed state with Taken label and check icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicineReminderCard(
              medicineName: 'Amoxicillin',
              dosage: '500 mg',
              instructions: 'Take with food',
              scheduledTime: '08:00 AM',
              isTaken: true,
            ),
          ),
        ),
      );

      expect(find.text('Amoxicillin'), findsOneWidget);
      expect(find.text('Taken'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    });

    testWidgets('Triggers onMarkTaken callback when tap action is performed', (tester) async {
      bool markedTaken = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicineReminderCard(
              medicineName: 'Metformin',
              dosage: '500 mg',
              instructions: 'Take with dinner',
              scheduledTime: '08:00 PM',
              isTaken: false,
              onMarkTaken: () {
                markedTaken = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mark Taken'));
      await tester.pump();

      expect(markedTaken, isTrue);
    });

    testWidgets('Triggers onEdit and onDelete callbacks', (tester) async {
      bool edited = false;
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicineReminderCard(
              medicineName: 'Lisinopril',
              dosage: '10 mg',
              instructions: 'Morning with water',
              scheduledTime: '07:30 AM',
              isTaken: false,
              showActions: true,
              onEdit: () {
                edited = true;
              },
              onDelete: () {
                deleted = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pump();
      expect(edited, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump();
      expect(deleted, isTrue);
    });

    testWidgets('Hides action buttons when showActions is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicineReminderCard(
              medicineName: 'Aspirin',
              dosage: '81 mg',
              instructions: 'Cardio protection',
              scheduledTime: '08:00 AM',
              isTaken: false,
              showActions: false,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('Handles long text without rendering overflow errors', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(320, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MedicineReminderCard(
                medicineName: 'Supercalifragilisticexpialidocious Long Medicine Name Extraordinaire',
                dosage: '1000 milligrams daily extended-release micro-encapsulated formula',
                instructions: 'Take strictly following complex clinical guidance with full hydration and nutritious meal.',
                scheduledTime: '11:45 PM',
                isTaken: false,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
