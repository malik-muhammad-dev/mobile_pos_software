import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// The blue panel's content — the shop's own identity, front and center.
/// On Setup Wizard this updates live as the owner types the shop name, so
/// the screen visibly becomes theirs while they're still setting it up.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.onPrimary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headlineXl.copyWith(color: AppColors.onPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: AppTypography.bodyLg.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.75)),
          ),
        ],
      ],
    );
  }
}