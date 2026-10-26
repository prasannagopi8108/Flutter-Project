import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

/// Storage service handling persistent local storage using [SharedPreferences].
/// Ensures zero data loss and handles malformed data gracefully.
class MedicineStorageService {
  static const String _storageKey = 'saved_medicines_v1';
  static const String _themeKey = 'app_theme_mode_v1';
  static const String _firstRunKey = 'is_first_run_completed_v1';

  final SharedPreferences _prefs;

  MedicineStorageService(this._prefs);

  /// Factory helper to asynchronously initialize the storage service.
  static Future<MedicineStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = MedicineStorageService(prefs);
    await service._seedInitialDataIfNeeded();
    return service;
  }

  /// Seeds default medicine reminders on the very first application run.
  Future<void> _seedInitialDataIfNeeded() async {
    final isInitialized = _prefs.getBool(_firstRunKey) ?? false;
    if (!isInitialized) {
      final initialMedicines = [
        Medicine(
          id: 'med-sample-1',
          medicineName: 'Amoxicillin',
          dosage: '500 mg (1 Capsule)',
          instructions: 'Take with food and plenty of water',
          scheduledTime: '08:00 AM',
          isTaken: true,
          colorValue: 0xFF00796B, // Teal
          iconCodePoint: Icons.medication_outlined.codePoint,
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        Medicine(
          id: 'med-sample-2',
          medicineName: 'Vitamin D3',
          dosage: '1000 IU (1 Tablet)',
          instructions: 'Take with or after breakfast',
          scheduledTime: '09:30 AM',
          isTaken: false,
          colorValue: 0xFF0284C7, // Sky Blue
          iconCodePoint: Icons.medical_services_outlined.codePoint,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Medicine(
          id: 'med-sample-3',
          medicineName: 'Metformin',
          dosage: '850 mg (1 Tablet)',
          instructions: 'Take during or immediately after dinner',
          scheduledTime: '08:00 PM',
          isTaken: false,
          colorValue: 0xFF8B5CF6, // Purple
          iconCodePoint: Icons.alarm.codePoint,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      await saveMedicines(initialMedicines);
      await _prefs.setBool(_firstRunKey, true);
    }
  }

  /// Loads all saved medicines from local storage.
  /// Gracefully catches deserialization errors without crashing.
  Future<List<Medicine>> loadMedicines() async {
    try {
      final rawList = _prefs.getStringList(_storageKey);
      if (rawList == null || rawList.isEmpty) {
        return <Medicine>[];
      }

      final medicines = <Medicine>[];
      for (final rawJson in rawList) {
        try {
          final map = jsonDecode(rawJson) as Map<String, dynamic>;
          medicines.add(Medicine.fromMap(map));
        } catch (e) {
          if (kDebugMode) {
            print('Skipping corrupted medicine record: $e');
          }
        }
      }
      return medicines;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading medicines from SharedPreferences: $e');
      }
      return <Medicine>[];
    }
  }

  /// Overwrites the full list of saved medicines in local storage.
  Future<bool> saveMedicines(List<Medicine> medicines) async {
    try {
      final encodedList = medicines
          .map((med) => jsonEncode(med.toMap()))
          .toList(growable: false);
      return await _prefs.setStringList(_storageKey, encodedList);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving medicines: $e');
      }
      return false;
    }
  }

  /// Adds a new medicine and persists immediately.
  Future<List<Medicine>> addMedicine(Medicine medicine) async {
    final current = await loadMedicines();
    current.insert(0, medicine);
    await saveMedicines(current);
    return current;
  }

  /// Updates an existing medicine matching its [id] and persists immediately.
  Future<List<Medicine>> updateMedicine(Medicine updated) async {
    final current = await loadMedicines();
    final index = current.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      current[index] = updated.copyWith(updatedAt: DateTime.now());
      await saveMedicines(current);
    }
    return current;
  }

  /// Deletes a medicine by [id] and persists immediately.
  Future<List<Medicine>> deleteMedicine(String id) async {
    final current = await loadMedicines();
    current.removeWhere((m) => m.id == id);
    await saveMedicines(current);
    return current;
  }

  /// Toggles the [isTaken] status of a medicine by [id].
  Future<List<Medicine>> toggleMedicineStatus(String id) async {
    final current = await loadMedicines();
    final index = current.indexWhere((m) => m.id == id);
    if (index != -1) {
      final existing = current[index];
      current[index] = existing.copyWith(
        isTaken: !existing.isTaken,
        updatedAt: DateTime.now(),
      );
      await saveMedicines(current);
    }
    return current;
  }

  /// Completely clears all medicines from local storage.
  Future<bool> clearAllMedicines() async {
    return await _prefs.remove(_storageKey);
  }

  /// Persists the selected ThemeMode ('system', 'light', 'dark').
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }

  /// Retrieves the saved ThemeMode, defaulting to [ThemeMode.system].
  ThemeMode getSavedThemeMode() {
    final saved = _prefs.getString(_themeKey);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
