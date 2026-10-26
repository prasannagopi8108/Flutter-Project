import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/medicine_storage_service.dart';
import 'utils/app_theme.dart';

/// The root application widget configuring themes, navigation, and local storage bindings.
class MedicineReminderApp extends StatefulWidget {
  final MedicineStorageService storageService;

  const MedicineReminderApp({
    super.key,
    required this.storageService,
  });

  @override
  State<MedicineReminderApp> createState() => _MedicineReminderAppState();
}

class _MedicineReminderAppState extends State<MedicineReminderApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.storageService.getSavedThemeMode();
  }

  void _handleThemeChanged() {
    setState(() {
      _themeMode = widget.storageService.getSavedThemeMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Reminder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        storageService: widget.storageService,
        onThemeChanged: _handleThemeChanged,
      ),
    );
  }
}
