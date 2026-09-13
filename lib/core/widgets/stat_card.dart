import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';

/// One stat tile in a dashboard-style top row — an icon badge, a small
/// label, and a large value. `accent` tints the icon badge so cards in the
/// same row read as distinct at a glance (e.g. blue for sales, amber for
/// udhar, or in Inventory: blue for stock, amber for low-stock alerts).
/// Shared across any screen that needs this pattern — started in Sales,
/// promoted here once Inventory needed the same shape.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Widget value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.xs),
          value,
        ],
      ),
    );
  }
}