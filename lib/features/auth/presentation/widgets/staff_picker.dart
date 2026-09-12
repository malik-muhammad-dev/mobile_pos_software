import 'package:flutter/material.dart';
import '../../../../core/services/staff_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';

/// "Who's logging in?" — tap your name, then type your PIN. Simpler and
/// safer than guessing whose PIN was typed from the PIN alone.
class StaffPicker extends StatelessWidget {
  const StaffPicker({super.key, required this.staff, required this.onSelect});

  final List<Staff> staff;
  final ValueChanged<Staff> onSelect;

  @override
  Widget build(BuildContext context) {
    if (staff.isEmpty) {
      return const EmptyState(
        icon: Icons.person_off_outlined,
        message: 'No staff yet. Ask the shop owner to add your account.',
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: staff.map((s) => _StaffRow(staff: s, onTap: () => onSelect(s))).toList(),
    );
  }
}

class _StaffRow extends StatelessWidget {
  const _StaffRow({required this.staff, required this.onTap});

  final Staff staff;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(initial, style: AppTypography.headlineSm.copyWith(color: AppColors.primary)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.name, style: AppTypography.bodyLg),
                  Text(
                    staff.role == StaffRole.owner ? 'Owner' : 'Cashier',
                    style: AppTypography.bodySm,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}