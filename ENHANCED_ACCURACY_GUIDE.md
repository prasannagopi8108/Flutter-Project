# Enhanced Accuracy Guide — Extending Schedules and Notifications

This technical guide provides architecture patterns and extension blueprints for extending the Medicine Reminder application with advanced scheduling patterns, reactive state management, and native push notifications.

---

## 1. Advanced Dosage Schedules

The current domain model (`Medicine`) includes `scheduledTime`, `startDate`, and `endDate`. To expand to complex clinical dosage schedules:

### A. Multiple Doses Per Day
For medications requiring intake multiple times a day (e.g., 3 times daily after meals), create a `DoseSchedule` child entity:

```dart
class ScheduledDose {
  final String doseId;
  final TimeOfDay time;
  final bool isTaken;
  final DateTime? takenAt;

  const ScheduledDose({
    required this.doseId,
    required this.time,
    this.isTaken = false,
    this.takenAt,
  });
}
```

### B. Cyclic and Finite Courses (e.g., 7-Day Antibiotics)
Validate whether the current date falls within active medication boundaries:

```dart
bool get isCourseActive {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (startDate != null && today.isBefore(startDate!)) return false;
  if (endDate != null && today.isAfter(endDate!)) return false;
  return true;
}
```

---

## 2. Scaling State Management

While this project utilizes clean dependency injection and vanilla Flutter state for simplicity and zero-overhead performance, it can easily scale to enterprise state management architectures:

### Riverpod Implementation Blueprint
```dart
final medicineStorageProvider = Provider<MedicineStorageService>((ref) {
  throw UnimplementedError(); // Initialized in main.dart
});

final medicineListProvider = AsyncNotifierProvider<MedicineListNotifier, List<Medicine>>(
  MedicineListNotifier.new,
);

class MedicineListNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    final storage = ref.watch(medicineStorageProvider);
    return storage.loadMedicines();
  }

  Future<void> toggleDose(String id) async {
    final storage = ref.read(medicineStorageProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => storage.toggleMedicineStatus(id));
  }
}
```

---

## 3. Background Alarm & Push Notifications Guide

To add native system notifications that trigger when the app is killed or running in the background, follow these steps:

### A. Recommended Package
Add `flutter_local_notifications` and `timezone` to `pubspec.yaml`:
```yaml
dependencies:
  flutter_local_notifications: ^17.1.2
  timezone: ^0.9.2
```

### B. Android Permissions & Setup
In `android/app/src/main/AndroidManifest.xml`, configure system permissions:

```xml
<!-- Required for Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Required for exact alarm scheduling -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<!-- Optional: Wake lock and restart reminders after device reboot -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

Register the alarm receiver inside `<application>`:
```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    </intent-filter>
</receiver>
```

### C. Web Notifications & Limitations
- Web browsers cannot execute background Dart code while the tab or browser is closed unless registered with a **Service Worker**.
- Web Notifications API requires user opt-in (`Notification.requestPermission()`).
- In `web/index.html`, listen for Web Push notifications or use Firebase Cloud Messaging (FCM) service workers for server-triggered alerts.
