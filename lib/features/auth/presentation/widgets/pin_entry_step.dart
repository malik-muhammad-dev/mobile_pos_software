import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import 'auth_scaffold.dart';
import 'pin_dots_input.dart';

/// One "type a PIN" step — reused by both the Setup Wizard (create PIN,
/// confirm PIN) and Login (enter PIN). Only the copy and callbacks differ.
class PinEntryStep extends StatelessWidget {
  const PinEntryStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pinController,
    required this.onCompleted,
    this.onBack,
    this.backLabel = 'Back',
  });

  final String title;
  final String subtitle;
  final TextEditingController pinController;
  final ValueChanged<String> onCompleted;
  final VoidCallback? onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: title,
      subtitle: subtitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PinDotsInput(controller: pinController, onCompleted: onCompleted),
          if (onBack != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: onBack, child: Text(backLabel)),
          ],
        ],
      ),
    );
  }
}