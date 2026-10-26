import 'package:flutter/material.dart';
import '../services/medicine_storage_service.dart';

/// Settings screen providing theme switching, data management, and platform notes.
class SettingsScreen extends StatefulWidget {
  final MedicineStorageService storageService;
  final VoidCallback onThemeChanged;
  final VoidCallback onDataCleared;

  const SettingsScreen({
    super.key,
    required this.storageService,
    required this.onThemeChanged,
    required this.onDataCleared,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _currentThemeMode = widget.storageService.getSavedThemeMode();
  }

  Future<void> _updateTheme(ThemeMode mode) async {
    setState(() => _currentThemeMode = mode);
    await widget.storageService.saveThemeMode(mode);
    widget.onThemeChanged();
  }

  /// Dialog confirmation to clear all data
  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('Reset All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all scheduled medicines and intake history from this device storage. Are you sure you wish to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.storageService.clearAllMedicines();
      widget.onDataCleared();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All local medication data has been erased.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              // Appearance Section
              Text(
                'APPEARANCE & THEME',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8.0),
              Card(
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      subtitle: const Text('Follows system dark/light configuration'),
                      secondary: const Icon(Icons.brightness_auto_rounded),
                      value: ThemeMode.system,
                      groupValue: _currentThemeMode,
                      onChanged: (val) => _updateTheme(val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light Mode'),
                      subtitle: const Text('Clean teal healthcare theme with light background'),
                      secondary: const Icon(Icons.light_mode_rounded),
                      value: ThemeMode.light,
                      groupValue: _currentThemeMode,
                      onChanged: (val) => _updateTheme(val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Sleek dark theme reducing eye strain in low light'),
                      secondary: const Icon(Icons.dark_mode_rounded),
                      value: ThemeMode.dark,
                      groupValue: _currentThemeMode,
                      onChanged: (val) => _updateTheme(val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Storage & Data Section
              Text(
                'DATA & PERSISTENCE',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8.0),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storage_rounded, color: Color(0xFF0284C7)),
                      title: const Text('Storage Engine'),
                      subtitle: const Text('SharedPreferences (HTML5 localStorage on Web, SQLite/Key-Value on Android & Windows)'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                      title: const Text('Clear All Medication Data'),
                      subtitle: const Text('Erases all stored records and resets schedule'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _confirmClearData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Platform & Notification Notes Section
              Text(
                'PLATFORM CAPABILITIES & LIMITATIONS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF00796B)),
                          const SizedBox(width: 8),
                          Text(
                            'Platform Storage Scope',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Browser-based storage (HTML5 localStorage) is sandboxed to the active domain and origin. '
                        'It is independent from Android SQLite/EncryptedSharedPreferences or Windows local app data.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined, size: 20, color: Colors.orangeAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Notification Policy',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'In accordance with clean architecture guidelines, system-level background alarms require '
                        'platform-specific services (POST_NOTIFICATIONS & SCHEDULE_EXACT_ALARM on Android 13+, '
                        'and Web Notifications API with Service Workers for browsers). This app focuses on robust '
                        'in-app adherence tracking without requiring unverified external daemon dependencies.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Application Information
              Text(
                'ABOUT APPLICATION',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medicine Reminder App',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      const SizedBox(height: 4.0),
                      const Text(
                        'Version 1.0.0 (Production Release)',
                        style: TextStyle(fontSize: 13.0, color: Colors.grey),
                      ),
                      const SizedBox(height: 12.0),
                      const Text(
                        'Built with Flutter & Dart using the Material 3 design system. Features modular architecture, '
                        'reusable custom MedicineReminderCard widget, persistent local storage, and zero external backend lock-in.',
                        style: TextStyle(fontSize: 13.0, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}
