import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/inventory_controller.dart';

/// Segmented iPhone / Android switcher — a pill container with two tap
/// targets, not a default Material TabBar, so it reads as one deliberate
/// control rather than borrowed chrome.
class InventoryTabSwitcher extends StatelessWidget {
  const InventoryTabSwitcher({super.key, required this.selected, required this.onChanged});

  final InventoryTab selected;
  final ValueChanged<InventoryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(context, tab: InventoryTab.iphone, label: 'iPhone', icon: Icons.phone_iphone_outlined),
          _segment(context, tab: InventoryTab.android, label: 'Android', icon: Icons.android_outlined),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, {required InventoryTab tab, required String label, required IconData icon}) {
    final isSelected = tab == selected;
    return GestureDetector(
      onTap: () => onChanged(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.onPrimary : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelLg.copyWith(
                color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}