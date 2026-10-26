import 'package:flutter/material.dart';

/// Reusable metric card displaying a single summary statistic.
class SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(isDark ? 0.25 : 0.12)
                  : (isDark ? theme.colorScheme.surface : Colors.white),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(icon, color: color, size: 18.0),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
