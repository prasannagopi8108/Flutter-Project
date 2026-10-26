import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/medicine_storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_time_utils.dart';

/// Screen for adding a new medicine or editing an existing one.
class AddMedicineScreen extends StatefulWidget {
  final MedicineStorageService storageService;
  final Medicine? medicineToEdit;

  const AddMedicineScreen({
    super.key,
    required this.storageService,
    this.medicineToEdit,
  });

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  DateTime? _startDate;
  DateTime? _endDate;
  late Color _selectedColor;
  late IconData _selectedIcon;
  bool _isSaving = false;

  bool get _isEditing => widget.medicineToEdit != null;

  @override
  void initState() {
    super.initState();
    final med = widget.medicineToEdit;

    _nameController = TextEditingController(text: med?.medicineName ?? '');
    _dosageController = TextEditingController(text: med?.dosage ?? '');
    _instructionsController = TextEditingController(text: med?.instructions ?? '');

    if (med != null) {
      _selectedTime = DateTimeUtils.parseTimeOfDay(med.scheduledTime);
      _startDate = med.startDate;
      _endDate = med.endDate;
      _selectedColor = med.color;
      _selectedIcon = med.icon;
    } else {
      _selectedColor = AppTheme.medicineColors.first;
      _selectedIcon = AppTheme.medicineIcons.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  /// Opens the Flutter TimePicker dialog.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Opens the Flutter DatePicker dialog for start date.
  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  /// Opens the Flutter DatePicker dialog for end date.
  Future<void> _pickEndDate() async {
    final baseDate = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? baseDate,
      firstDate: baseDate,
      lastDate: baseDate.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  /// Validates and persists the medicine.
  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final scheduledTimeString = DateTimeUtils.formatTimeOfDay(_selectedTime);

      if (_isEditing) {
        final updated = widget.medicineToEdit!.copyWith(
          medicineName: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          instructions: _instructionsController.text.trim(),
          scheduledTime: scheduledTimeString,
          startDate: _startDate,
          endDate: _endDate,
          colorValue: _selectedColor.value,
          iconCodePoint: _selectedIcon.codePoint,
          updatedAt: DateTime.now(),
        );
        await widget.storageService.updateMedicine(updated);
      } else {
        final newMedicine = Medicine(
          id: 'med_${DateTime.now().millisecondsSinceEpoch}',
          medicineName: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          instructions: _instructionsController.text.trim(),
          scheduledTime: scheduledTimeString,
          startDate: _startDate,
          endDate: _endDate,
          isTaken: false,
          colorValue: _selectedColor.value,
          iconCodePoint: _selectedIcon.codePoint,
          createdAt: DateTime.now(),
        );
        await widget.storageService.addMedicine(newMedicine);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Updated "${_nameController.text.trim()}" successfully.'
                  : 'Added "${_nameController.text.trim()}" to schedule.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save medicine: $e'),
            backgroundColor: Colors.redAccent,
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
        title: Text(_isEditing ? 'Edit Medicine' : 'Add New Medicine'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveMedicine,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              children: [
                // Medicine Name
                Text(
                  'Medicine Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name *',
                    hintText: 'e.g. Amoxicillin, Vitamin D',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the medicine name';
                    }
                    if (value.trim().length < 2) {
                      return 'Medicine name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14.0),

                // Dosage
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage / Strength *',
                    hintText: 'e.g. 500 mg, 1 tablet, 2 drops',
                    prefixIcon: Icon(Icons.format_list_numbered_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please specify the dosage';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14.0),

                // Instructions
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Intake Instructions',
                    hintText: 'e.g. Take after meal with water',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24.0),

                // Scheduled Time Picker
                Text(
                  'Schedule & Timing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.surface : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_filled_rounded, color: theme.colorScheme.primary),
                            const SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Scheduled Dose Time',
                                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                ),
                                Text(
                                  DateTimeUtils.formatTimeOfDay(_selectedTime),
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: _pickTime,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Change Time'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),

                // Optional Start & End Dates Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartDate,
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isDark ? theme.colorScheme.surface : Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                              const SizedBox(height: 4.0),
                              Text(
                                _startDate != null
                                    ? DateTimeUtils.formatShortDate(_startDate!)
                                    : 'Today',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndDate,
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isDark ? theme.colorScheme.surface : Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('End Date', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    _endDate != null
                                        ? DateTimeUtils.formatShortDate(_endDate!)
                                        : 'Ongoing',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (_endDate != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  splashRadius: 14,
                                  onPressed: () => setState(() => _endDate = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Accent Color Selector
                Text(
                  'Color Accent',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 10.0,
                  children: AppTheme.medicineColors.map((color) {
                    final isSelected = _selectedColor.value == color.value;
                    return InkWell(
                      onTap: () => setState(() => _selectedColor = color),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24.0),

                // Icon Selector
                Text(
                  'Visual Icon',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 10.0,
                  children: AppTheme.medicineIcons.map((iconData) {
                    final isSelected = _selectedIcon.codePoint == iconData.codePoint;
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = iconData),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48.0,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withOpacity(0.18)
                              : (isDark ? theme.colorScheme.surface : Colors.white),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Icon(
                          iconData,
                          color: isSelected ? _selectedColor : Colors.grey,
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36.0),

                // Action Buttons: Save & Cancel
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMedicine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isEditing ? 'Update Medicine' : 'Save Medicine',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
