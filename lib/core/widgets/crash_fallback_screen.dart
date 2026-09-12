import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Registered as ErrorWidget.builder in main.dart so an unhandled widget
/// error never puts a stack trace in front of shop staff — just this calm,
/// plain-language screen instead.
class CrashFallbackScreen extends StatelessWidget {
  const CrashFallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: AppColors.canvas,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
              SizedBox(height: 16),
              Text('Something went wrong.', style: AppTypography.headlineMd),
              SizedBox(height: 8),
              Text('Please restart the app.', style: AppTypography.bodyLg),
            ],
          ),
        ),
      ),
    );
  }
}