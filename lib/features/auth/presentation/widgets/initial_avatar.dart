import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// A circular avatar showing someone's first initial — the small staff
/// picker rows and the larger personalized PIN-step header share this.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.1)),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontSize: size * 0.4),
      ),
    );
  }
}