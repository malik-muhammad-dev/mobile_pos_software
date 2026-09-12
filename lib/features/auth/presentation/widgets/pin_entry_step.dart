import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'pin_dots_input.dart';

/// One "type a PIN" step — reused by Setup Wizard (create/confirm PIN) and
/// Login (enter PIN). `leading` is whatever sits above the title: step
/// dots for Setup Wizard, a big personalized avatar for Login.
class PinEntryStep extends StatelessWidget {
  const PinEntryStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pinController,
    required this.onCompleted,
    this.onBack,
    this.backLabel = 'Back',
    this.leading,
  });

  final String title;
  final String subtitle;
  final TextEditingController pinController;
  final ValueChanged<String> onCompleted;
  final VoidCallback? onBack;
  final String backLabel;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(height: AppSpacing.lg)],
        Text(title, style: AppTypography.headlineLg, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTypography.bodyMd, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xl),
        PinDotsInput(controller: pinController, onCompleted: onCompleted),
        if (onBack != null) ...[
          const SizedBox(height: AppSpacing.lg),
          TextButton(onPressed: onBack, child: Text(backLabel)),
        ],
      ],
    );
  }
}