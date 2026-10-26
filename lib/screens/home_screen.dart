import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/medicine_storage_service.dart';
import '../utils/date_time_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/medicine_reminder_card.dart';
import '../widgets/summary_card.dart';
import 'add_medicine_screen.dart';
import 'settings_screen.dart';

enum MedicineFilter { all, pending, completed }

/// Main Home Screen displaying today's scheduled medicines, status filters, and summary metrics.
class HomeScreen extends StatefulWidget {
  final MedicineStorageService storageService;
  final VoidCallback onThemeChanged;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medicine> _allMedicines = [];
  bool _isLoading = true;
  MedicineFilter _selectedFilter = MedicineFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads medicine list from storage service.
  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    final medicines = await widget.storageService.loadMedicines();
    if (mounted) {
      setState(() {
        _allMedicines = medicines;
        _isLoading = false;
      });
    }
  }

  /// Toggles completion status for a medicine.
  Future<void> _toggleMedicine(Medicine medicine) async {
    final updatedList = await widget.storageService.toggleMedicineStatus(medicine.id);
    if (!mounted) return;

    setState(() {
      _allMedicines = updatedList;
    });

    final nowTaken = !medicine.isTaken;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              nowTaken ? Icons.check_circle_rounded : Icons.undo_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nowTaken
                    ? '${medicine.medicineName} marked as taken!'
                    : '${medicine.medicineName} marked as pending.',
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.amberAccent,
          onPressed: () => _toggleMedicine(
            medicine.copyWith(isTaken: nowTaken),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Prompts for confirmation before deleting a medicine.
  Future<void> _confirmDelete(Medicine medicine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delete Medicine',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${medicine.medicineName}"? This action cannot be undone.',
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              fontSize: 14.5,
              height: 1.4,
            ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final updatedList = await widget.storageService.deleteMedicine(medicine.id);
      setState(() {
        _allMedicines = updatedList;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${medicine.medicineName}".'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  /// Opens the Add or Edit Medicine screen.
  Future<void> _navigateToAddEditScreen([Medicine? medicine]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddMedicineScreen(
          storageService: widget.storageService,
          medicineToEdit: medicine,
        ),
      ),
    );

    if (result == true) {
      _loadMedicines();
    }
  }

  /// Navigates to Settings screen.
  Future<void> _navigateToSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          storageService: widget.storageService,
          onThemeChanged: widget.onThemeChanged,
          onDataCleared: _loadMedicines,
        ),
      ),
    );
  }

  /// Filters medicines according to tab filter and search term.
  List<Medicine> get _filteredMedicines {
    return _allMedicines.where((med) {
      // Status filter
      if (_selectedFilter == MedicineFilter.pending && med.isTaken) return false;
      if (_selectedFilter == MedicineFilter.completed && !med.isTaken) return false;

      // Query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = med.medicineName.toLowerCase().contains(query);
        final matchesDosage = med.dosage.toLowerCase().contains(query);
        final matchesInstructions = med.instructions.toLowerCase().contains(query);
        return matchesName || matchesDosage || matchesInstructions;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalCount = _allMedicines.length;
    final completedCount = _allMedicines.where((m) => m.isTaken).length;
    final pendingCount = totalCount - completedCount;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    final filteredList = _filteredMedicines;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medicine Reminder'),
            Text(
              DateTimeUtils.formatHeaderDate(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.normal,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _navigateToSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditScreen(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Medicine'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Summary Cards Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Row(
                          children: [
                            SummaryCard(
                              label: 'Total',
                              count: totalCount,
                              icon: Icons.medication_rounded,
                              color: const Color(0xFF0284C7),
                              isSelected: _selectedFilter == MedicineFilter.all,
                              onTap: () {
                                setState(() => _selectedFilter = MedicineFilter.all);
                              },
                            ),
                            const SizedBox(width: 10.0),
                            SummaryCard(
                              label: 'Completed',
                              count: completedCount,
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF16A34A),
                              isSelected: _selectedFilter == MedicineFilter.completed,
                              onTap: () {
                                setState(() => _selectedFilter = MedicineFilter.completed);
                              },
                            ),
                            const SizedBox(width: 10.0),
                            SummaryCard(
                              label: 'Pending',
                              count: pendingCount,
                              icon: Icons.pending_actions_rounded,
                              color: const Color(0xFFF59E0B),
                              isSelected: _selectedFilter == MedicineFilter.pending,
                              onTap: () {
                                setState(() => _selectedFilter = MedicineFilter.pending);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Overall Progress Banner
                    if (totalCount > 0)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: isDark ? theme.colorScheme.surface : Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Daily Adherence Progress',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: completedCount == totalCount && totalCount > 0
                                          ? const Color(0xFF16A34A)
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8.0,
                                  backgroundColor: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF1F5F9),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    completedCount == totalCount && totalCount > 0
                                        ? const Color(0xFF16A34A)
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Filter Segmented Buttons & Search
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            // Search bar
                            TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() => _searchQuery = val.trim());
                              },
                              decoration: InputDecoration(
                                hintText: 'Search medicines...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 10.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            // Segmented Button
                            SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<MedicineFilter>(
                                segments: const [
                                  ButtonSegment(
                                    value: MedicineFilter.all,
                                    label: Text('All'),
                                    icon: Icon(Icons.list_alt_rounded, size: 16),
                                  ),
                                  ButtonSegment(
                                    value: MedicineFilter.pending,
                                    label: Text('Pending'),
                                    icon: Icon(Icons.hourglass_empty_rounded, size: 16),
                                  ),
                                  ButtonSegment(
                                    value: MedicineFilter.completed,
                                    label: Text('Completed'),
                                    icon: Icon(Icons.check_circle_outline_rounded, size: 16),
                                  ),
                                ],
                                selected: {_selectedFilter},
                                onSelectionChanged: (newSelection) {
                                  setState(() {
                                    _selectedFilter = newSelection.first;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section Title Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SCHEDULED MEDICINES (${filteredList.length})',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            if (filteredList.isNotEmpty)
                              Text(
                                'Tap card button to toggle',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Medicines List or Empty State
                    if (filteredList.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          title: _allMedicines.isEmpty
                              ? 'No Medicines Added'
                              : 'No Matching Reminders',
                          message: _allMedicines.isEmpty
                              ? 'Start maintaining your health schedule by adding your medications.'
                              : 'No medicines match the selected filter or search keyword.',
                          actionLabel: _allMedicines.isEmpty ? 'Add Medicine' : null,
                          onActionPressed: _allMedicines.isEmpty
                              ? () => _navigateToAddEditScreen()
                              : null,
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final medicine = filteredList[index];
                            return MedicineReminderCard(
                              key: ValueKey(medicine.id),
                              medicineName: medicine.medicineName,
                              dosage: medicine.dosage,
                              instructions: medicine.instructions,
                              scheduledTime: medicine.scheduledTime,
                              isTaken: medicine.isTaken,
                              medicineColor: medicine.color,
                              icon: medicine.icon,
                              showActions: true,
                              borderRadius: 16.0,
                              onMarkTaken: () => _toggleMedicine(medicine),
                              onEdit: () => _navigateToAddEditScreen(medicine),
                              onDelete: () => _confirmDelete(medicine),
                            );
                          },
                          childCount: filteredList.length,
                        ),
                      ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80.0),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
