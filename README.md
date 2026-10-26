# Medicine Reminder — Complete Flutter Application

[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2.svg)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Design-Material%203-teal.svg)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
🚀 **Live Demo:** [https://flutter-project-jpxk.onrender.com/]
A production-quality, responsive **Medicine Reminder** application built with Flutter and Dart. Designed with modern healthcare aesthetics, Material 3 theming, persistent local storage, and a truly reusable `MedicineReminderCard` widget that runs seamlessly across Web, Android, Windows, and iOS.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Reusable `MedicineReminderCard` Widget](#reusable-medicineremindercard-widget)
- [Architecture & Folder Structure](#architecture--folder-structure)
- [UI & Screenshots](#ui--screenshots)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Running the Application](#running-the-application)
- [Running Tests](#running-tests)
- [Building & Deploying for Web](#building--deploying-for-web)
- [Platform Storage & Notification Notes](#platform-storage--notification-notes)
- [Troubleshooting](#troubleshooting)

---

## Overview

The **Medicine Reminder App** simplifies daily medication management for patients, caregivers, and health-conscious individuals. Built around a clean medical teal color palette, the application provides intuitive dose tracking, adherence calculation, quick search filtering, and persistent local storage with zero required API keys or backend server lock-in.

---

## Key Features

- **Daily Adherence Tracking**: Real-time progress bar reflecting doses taken versus doses scheduled.
- **Interactive Summary Dashboard**: Metric cards displaying Total, Completed, and Pending counts with interactive filtering.
- **Reusable `MedicineReminderCard`**: Completely self-contained presentational widget with configurable properties, custom action callbacks, accessible touch targets, and visual completion indicators.
- **Robust Persistence**: Powered by `SharedPreferences` (HTML5 `localStorage` on Web, platform key-value store on Android & Windows) with corruption-proof JSON deserialization.
- **Full Medication Management (CRUD)**: Add, edit, mark taken/pending, and safely delete reminders with confirmation dialogs.
- **Search & Filter**: Search medications in real-time by name, dosage, or instructions, and filter by status (*All*, *Pending*, *Completed*).
- **Material 3 Theme Engine**: Seamless support for Light, Dark, and System default themes.
- **Responsive Layout**: Adapts gracefully from mobile portrait viewports to large desktop and web screens with width constraints.

---

## Reusable `MedicineReminderCard` Widget

The card is located at:
`lib/widgets/medicine_reminder_card.dart`

It is strictly decoupled from storage, database, and navigation logic, accepting purely configurable parameters and callbacks.

### Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `medicineName` | `String` | Yes | - | Name of the medication (e.g. "Vitamin D3") |
| `dosage` | `String` | Yes | - | Quantity or strength (e.g. "1000 IU (1 Tablet)") |
| `instructions` | `String` | Yes | - | Intake directions (e.g. "Take after breakfast") |
| `scheduledTime` | `String` | Yes | - | Scheduled time string (e.g. "09:00 AM") |
| `isTaken` | `bool` | Yes | - | Completion status of the scheduled dose |
| `onMarkTaken` | `VoidCallback?` | No | `null` | Callback triggered when user toggles mark taken |
| `onEdit` | `VoidCallback?` | No | `null` | Callback triggered when edit button is tapped |
| `onDelete` | `VoidCallback?` | No | `null` | Callback triggered when delete button is tapped |
| `medicineColor` | `Color?` | No | `primary` | Accent color for the strip, icon, and button |
| `icon` | `IconData?` | No | `Icons.medication_outlined` | Custom medication icon |
| `showActions` | `bool` | No | `true` | Whether to display the edit and delete buttons |
| `borderRadius` | `double` | No | `16.0` | Card corner radius in logical pixels |
| `key` | `Key?` | No | `null` | Standard Flutter widget key |

### Example Usage

```dart
import 'package:flutter/material.dart';
import 'package:medicine_reminder/widgets/medicine_reminder_card.dart';

MedicineReminderCard(
  medicineName: 'Vitamin D',
  dosage: '1 tablet',
  instructions: 'Take after breakfast with water',
  scheduledTime: '09:00 AM',
  isTaken: false,
  medicineColor: const Color(0xFF0284C7),
  icon: Icons.medication_outlined,
  borderRadius: 16.0,
  showActions: true,
  onMarkTaken: () {
    print('Toggled dose completion');
  },
  onEdit: () {
    print('Edit requested');
  },
  onDelete: () {
    print('Delete requested');
  },
)
```

---

## Architecture & Folder Structure

```text
medicine_reminder/
├── android/                   # Android native configuration and build scripts
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/main/AndroidManifest.xml
│   ├── gradle.properties
│   ├── settings.gradle.kts
│   └── build.gradle.kts
├── ios/                       # iOS native configuration
│   └── Runner/
│       ├── AppDelegate.swift
│       └── Info.plist
├── web/                       # Web bootstrap and PWA assets
│   ├── index.html
│   ├── manifest.json
│   ├── favicon.png
│   └── icons/
│       ├── Icon-192.png
│       └── Icon-512.png
├── windows/                   # Windows desktop runner and CMake configuration
│   ├── CMakeLists.txt
│   └── runner/
├── lib/                       # Application source code
│   ├── main.dart              # Entry point with async initialization
│   ├── app.dart               # Root MaterialApp with theme bindings
│   ├── models/
│   │   └── medicine.dart      # Strongly typed domain model with serialization
│   ├── screens/
│   │   ├── home_screen.dart   # Dashboard, filters, progress, and reminder list
│   │   ├── add_medicine_screen.dart # Add / edit medication form
│   │   └── settings_screen.dart     # Themes, data reset, and platform info
│   ├── widgets/
│   │   ├── medicine_reminder_card.dart # Reusable presentation widget
│   │   ├── summary_card.dart  # Metric counter cards
│   │   └── empty_state.dart   # Zero-data feedback placeholder
│   ├── services/
│   │   └── medicine_storage_service.dart # SharedPreferences persistent engine
│   └── utils/
│       ├── app_theme.dart     # Material 3 Light and Dark design tokens
│       └── date_time_utils.dart # Formatter and parser utilities
├── test/                      # Comprehensive test suite
│   ├── medicine_model_test.dart
│   ├── medicine_reminder_card_test.dart
│   └── widget_test.dart
├── pubspec.yaml               # Package dependencies & assets
├── analysis_options.yaml      # Strict Flutter lint rules
├── vercel.json                # Vercel SPA deployment configuration
├── netlify.toml               # Netlify deployment configuration
├── firebase.json              # Firebase Hosting configuration
├── README.md                  # Project documentation
├── DEPLOYMENT.md              # Deployment guide
├── ACCURACY_ENHANCEMENT_SUMMARY.md
├── CLEANUP_SUMMARY.md
├── ENHANCED_ACCURACY_GUIDE.md
└── ENHANCED_DOCUMENT_HANDLING.md
```

---

## UI & Screenshots

| Home Dashboard (Light) | Completed State & Progress | Add / Edit Medicine |
| :---: | :---: | :---: |
| *(Header date, Total/Pending cards, Scheduled list)* | *(Green checkmark, strikethrough, adherence bar)* | *(Name, dosage, time picker, color & icon picker)* |

---

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.19.0 or higher recommended).
- [Dart SDK](https://dart.dev/get-dart) (version 3.3.0 or higher).
- Supported browser (Google Chrome, Edge, Safari, Firefox) for Flutter Web.
- Android Studio / Android SDK (API 34) for Android builds.
- Visual Studio 2022 with C++ desktop workload for Windows builds.

---

## Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/prasannagopi8108/Flutter-Project.git
   cd Flutter-Project
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify installation**:
   ```bash
   flutter doctor
   ```

---

## Running the Application

### Flutter Web (Chrome)
```bash
flutter run -d chrome
```

### Windows Desktop
```bash
flutter run -d windows
```

### Android Emulator or Physical Device
```bash
flutter run -d android
```

---

## Running Tests

Execute the automated test suite covering unit models, widget callbacks, and integration workflows:

```bash
# Run all tests
flutter test

# Format code
dart format .

# Analyze for lint errors and type safety
flutter analyze
```

---

## Building & Deploying for Web

Build an optimized production bundle:

```bash
flutter build web --release
```

The compiled static assets will be located in the `build/web` directory.

### Quick Deploy Options

#### Vercel
```bash
npm install -g vercel
vercel --prod
```
*(The repository includes a ready-to-use [vercel.json](file:///c:/Users/prasa/OneDrive/Desktop/Flutter/Flutter-Project/vercel.json) configured for single-page application routing).*

#### Netlify
```bash
npm install -g netlify-cli
netlify deploy --prod --dir=build/web
```
*(The repository includes [netlify.toml](file:///c:/Users/prasa/OneDrive/Desktop/Flutter/Flutter-Project/netlify.toml) with redirect rules).*

#### Firebase Hosting
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy --only hosting
```
*(Configured in [firebase.json](file:///c:/Users/prasa/OneDrive/Desktop/Flutter/Flutter-Project/firebase.json) with public folder set to `build/web`).*

---

## Platform Storage & Notification Notes

- **Local Storage Isolation**: Browser-based storage utilizes HTML5 `localStorage` which is isolated by domain/subdomain and origin. It operates independently from native Android `SharedPreferences` or Windows app data directories.
- **Background Notifications**: In accordance with senior architecture standards, system-level background alarms require native daemon background services (`POST_NOTIFICATIONS` and `SCHEDULE_EXACT_ALARM` permissions on Android 13+, and Service Worker Notifications API for web). This application strictly focuses on verified in-app adherence tracking without introducing unverified or paid third-party dependencies.

---

## Troubleshooting

1. **`Target of URI doesn't exist`**:
   Run `flutter pub get` to download and generate dependencies.
2. **Web loading spinner hangs**:
   Ensure `flutter build web` was executed so `flutter.js` and `main.dart.js` exist in `build/web`.
3. **Resetting corrupt data**:
   Navigate to **Settings** > **Clear All Medication Data** to reset the storage store.
