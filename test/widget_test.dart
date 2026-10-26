import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicine_reminder/app.dart';
import 'package:medicine_reminder/services/medicine_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders Home Screen with summary cards and initial list', (tester) async {
    // Set up mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final storageService = await MedicineStorageService.init();

    await tester.pumpWidget(MedicineReminderApp(storageService: storageService));
    await tester.pumpAndSettle();

    // Verify AppBar Title
    expect(find.text('Medicine Reminder'), findsOneWidget);

    // Verify Summary Cards
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    // Verify initial seeded sample medicines exist
    expect(find.text('Amoxicillin'), findsOneWidget);
    expect(find.text('Vitamin D3'), findsOneWidget);

    // Verify Add Medicine FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Filtering by Completed hides pending medicines', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await MedicineStorageService.init();

    await tester.pumpWidget(MedicineReminderApp(storageService: storageService));
    await tester.pumpAndSettle();

    // Tap on Completed filter segment
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();

    // In initial seed, Amoxicillin is completed (isTaken: true) and Vitamin D3 is pending (isTaken: false)
    expect(find.text('Amoxicillin'), findsOneWidget);
    expect(find.text('Vitamin D3'), findsNothing);
  });
}
