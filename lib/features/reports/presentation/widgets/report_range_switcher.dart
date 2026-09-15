import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/reports_controller.dart';

/// Segmented range switcher — same pill-container pattern as Inventory's
/// iPhone/Android switcher, extended to 4 segments. Wrapped in horizontal
/// scroll so it never overflows a narrowed window instead of squeezing
/// four labels into too little space.
class ReportRangeSwitcher extends StatelessWidget {
  const ReportRangeSwitcher({super.key, required this.selected, required this.onChanged});

  final ReportRange selected;
  final ValueChanged<ReportRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [for (final range in ReportRange.values) _segment(range)],
        ),
      ),
    );
  }

  Widget _segment(ReportRange range) {
    final isSelected = range == selected;
    return GestureDetector(
      onTap: () => onChanged(range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          range.label,
          style: AppTypography.labelLg.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}