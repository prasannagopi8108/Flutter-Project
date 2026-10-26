import 'package:flutter/material.dart';
import 'app.dart';
import 'services/medicine_storage_service.dart';

/// Application entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent local storage
  final storageService = await MedicineStorageService.init();

  runApp(MedicineReminderApp(storageService: storageService));
}
