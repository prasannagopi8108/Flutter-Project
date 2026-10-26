import 'package:flutter/material.dart';

/// A reusable, responsive card widget that displays a single scheduled medicine reminder.
///
/// Designed in accordance with Material 3 principles and accessibility standards.
/// Contains no internal business or persistence logic, making it fully reusable across screens.
class MedicineReminderCard extends StatelessWidget {
  /// Name of the medicine (e.g. 'Vitamin D', 'Amoxicillin').
  final String medicineName;

  /// Quantity or dose format (e.g. '1 tablet', '500 mg').
  final String dosage;

  /// Usage instructions (e.g. 'Take after breakfast').
  final String instructions;

  /// Display string of the scheduled dose time (e.g. '09:00 AM').
  final String scheduledTime;

  /// Whether the scheduled dose has been taken.
  final bool isTaken;

  /// Callback triggered when the user taps to toggle or mark the medicine as taken.
  final VoidCallback? onMarkTaken;

  /// Optional callback invoked when the user requests editing this medicine.
  final VoidCallback? onEdit;

  /// Optional callback invoked when the user requests deleting this medicine.
  final VoidCallback? onDelete;

  /// Accent color theme for this medication. Defaults to Material 3 Primary Teal.
  final Color? medicineColor;

  /// Leading icon representing the medication type. Defaults to [Icons.medication_outlined].
  final IconData? icon;

  /// Whether to display the edit and delete action buttons. Defaults to true.
  final bool showActions;

  /// Card border radius corner value in logical pixels. Defaults to 16.0.
  final double borderRadius;

  const MedicineReminderCard({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.instructions,
    required this.scheduledTime,
    required this.isTaken,
    this.onMarkTaken,
    this.onEdit,
    this.onDelete,
    this.medicineColor,
    this.icon,
    this.showActions = true,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = medicineColor ?? theme.colorScheme.primary;
    final radius = BorderRadius.circular(borderRadius);

    // Dynamic color styling based on completion state
    final cardBgColor = isTaken
        ? (isDark ? const Color(0xFF132A22) : const Color(0xFFF0FDF4))
        : (isDark ? theme.colorScheme.surface : Colors.white);

    final borderColor = isTaken
        ? (isDark ? const Color(0xFF065F46) : const Color(0xFFBBF7D0))
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    final titleColor = isTaken
        ? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534))
        : (isDark ? theme.colorScheme.onSurface : const Color(0xFF0F172A));

    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isTaken
                ? Colors.transparent
                : (isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04)),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Color Accent Strip
              Container(
                width: 6.0,
                color: isTaken ? const Color(0xFF22C55E) : primaryAccent,
              ),

              // Main Card Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Row: Leading Icon, Name, Dosage, and Status Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Leading Circular Icon Container
                          Container(
                            width: 44.0,
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: isTaken
                                  ? const Color(0xFF22C55E).withOpacity(0.15)
                                  : primaryAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Icon(
                              isTaken
                                  ? Icons.check_circle_rounded
                                  : (icon ?? Icons.medication_outlined),
                              color: isTaken
                                  ? const Color(0xFF16A34A)
                                  : primaryAccent,
                              size: 24.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),

                          // Medicine Title & Dosage
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicineName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                    decoration: isTaken
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: titleColor.withOpacity(0.7),
                                    decorationThickness: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  dosage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8.0),

                          // Scheduled Time Pill Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9.0,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13.0,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  scheduledTime,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Instructions (if provided)
                      if (instructions.trim().isNotEmpty) ...[
                        const SizedBox(height: 10.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withOpacity(0.18)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14.0,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 6.0),
                              Expanded(
                                child: Text(
                                  instructions,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: secondaryTextColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12.0),

                      // Bottom Action Controls Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Mark as Taken Toggle Button
                          InkWell(
                            onTap: onMarkTaken,
                            borderRadius: BorderRadius.circular(20.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 6.0,
                              ),
                              decoration: BoxDecoration(
                                color: isTaken
                                    ? const Color(0xFF16A34A)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isTaken
                                      ? const Color(0xFF16A34A)
                                      : primaryAccent,
                                  width: 1.4,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isTaken
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    size: 16.0,
                                    color: isTaken
                                        ? Colors.white
                                        : primaryAccent,
                                  ),
                                  const SizedBox(width: 6.0),
                                  Text(
                                    isTaken ? 'Taken' : 'Mark Taken',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isTaken
                                        ? Colors.white
                                        : primaryAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Edit and Delete Buttons (Visible when showActions is true)
                          if (showActions)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (onEdit != null)
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    iconSize: 19.0,
                                    color: secondaryTextColor,
                                    tooltip: 'Edit $medicineName',
                                    splashRadius: 18.0,
                                    constraints: const BoxConstraints(
                                      minWidth: 36.0,
                                      minHeight: 36.0,
                                    ),
                                    onPressed: onEdit,
                                  ),
                                if (onDelete != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded),
                                    iconSize: 19.0,
                                    color: Colors.redAccent.shade200,
                                    tooltip: 'Delete $medicineName',
                                    splashRadius: 18.0,
                                    constraints: const BoxConstraints(
                                      minWidth: 36.0,
                                      minHeight: 36.0,
                                    ),
                                    onPressed: onDelete,
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
