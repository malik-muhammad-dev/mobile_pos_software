import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Displays a 15-digit IMEI in letter-spaced tabular-figure clusters
/// (4-6-4-1) so a long digit string can actually be verified by eye against
/// a physical phone, rather than read as one dense blob.
class ImeiChip extends StatelessWidget {
  const ImeiChip(this.imei, {super.key});

  final String imei;

  String get _grouped {
    if (imei.length != 15) return imei;
    return '${imei.substring(0, 4)} ${imei.substring(4, 10)} ${imei.substring(10, 14)} ${imei.substring(14)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Text(
        _grouped,
        style: AppTypography.bodyMd.merge(AppTypography.numeric).copyWith(letterSpacing: 1),
      ),
    );
  }
}