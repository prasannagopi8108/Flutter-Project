import 'package:flutter/material.dart';

/// Clean empty state placeholder widget shown when no medicines are scheduled.
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    this.title = 'No Medicines Scheduled',
    this.message = 'Keep track of your health routine by adding your first medication reminder.',
    this.icon = Icons.medication_liquid_outlined,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88.0,
              height: 88.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 44.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add, size: 18.0),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
