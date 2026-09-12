import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Small progress indicator for the Setup Wizard's three steps, so it's
/// obvious this is a short, known-length process rather than open-ended.
class SetupStepDots extends StatelessWidget {
  const SetupStepDots({super.key, required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.borderDefault,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}