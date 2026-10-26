# Enhanced Document and Data Handling Guide

This guide details data management, persistence isolation, backup/export mechanisms, and disaster recovery strategies for the Medicine Reminder application.

---

## 1. Cross-Platform Persistence Architecture

The app uses `shared_preferences` as its primary persistence driver. Understanding the platform-specific storage engines is critical for production maintenance:

| Platform | Underlying Storage Engine | Storage Scope | File / Location |
|---|---|---|---|
| **Flutter Web** | `window.localStorage` / IndexedDB | Origin-isolated (Scheme + Domain + Port) | Browser SQLite / LevelDB database |
| **Android** | `SharedPreferences` XML / DataStore | App-isolated sandbox | `/data/data/<pkg>/shared_prefs/` |
| **Windows Desktop** | Windows Registry or Key-Value flat file | `%APPDATA%` User roaming folder | App data storage directory |
| **iOS / macOS** | `NSUserDefaults` plist | Sandboxed application container | App Library Preferences |

---

## 2. Exporting and Importing Medication Data

For patients sharing adherence records with healthcare providers or backing up their data across devices:

### JSON Export Format
```json
{
  "version": 1,
  "exportedAt": "2026-10-26T14:30:00Z",
  "medicines": [
    {
      "id": "med-1",
      "medicineName": "Amoxicillin",
      "dosage": "500 mg",
      "instructions": "Take after meals",
      "scheduledTime": "08:00 AM",
      "isTaken": true,
      "colorValue": 4278221163,
      "iconCodePoint": 58329,
      "createdAt": "2026-10-26T10:00:00.000Z"
    }
  ]
}
```

### Export / Import Implementation Blueprint
```dart
Future<String> exportMedicationsToJson(MedicineStorageService service) async {
  final medicines = await service.loadMedicines();
  final exportMap = {
    'version': 1,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'medicines': medicines.map((m) => m.toMap()).toList(),
  };
  return jsonEncode(exportMap);
}
```

---

## 3. Disaster Recovery & Schema Migration

- **Self-Healing Storage**: When reading the stored string list, corrupted entries are safely caught without dropping the remaining records.
- **Data Reset**: A confirmation-guarded reset option in `SettingsScreen` allows full recovery to a clean state.
