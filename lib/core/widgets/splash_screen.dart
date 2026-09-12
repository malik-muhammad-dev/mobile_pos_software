import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shown for the brief moment AppRoot is checking whether any staff exist
/// yet. Branded rather than a bare spinner — the very first thing anyone
/// sees when the app opens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.onPrimary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Mobile Shop POS',
              style: AppTypography.headlineLg.copyWith(color: AppColors.onPrimary),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}