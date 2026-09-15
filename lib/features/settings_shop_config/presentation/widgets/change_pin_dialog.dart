import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/widgets/pin_dots_input.dart';

/// Change the logged-in owner's PIN. Demo-grade for now — validates the
/// three fields client-side (new/confirm match, all 4 digits) but doesn't
/// touch the real pin_hash yet; there's no real "current PIN" to check
/// against until AuthService is wired to the real staff table.
class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_currentController.text.length != 4) {
      setState(() => _error = 'Enter your current PIN');
      return;
    }
    if (_newController.text.length != 4) {
      setState(() => _error = 'New PIN must be 4 digits');
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(() => _error = "New PIN and confirmation don't match");
      return;
    }

    Get.back();
    Get.snackbar(
      'PIN updated',
      "For the demo this isn't saved yet — real PIN storage comes with the AuthService wiring.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      insetPadding: const EdgeInsets.all(AppSpacing.gutterLg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(380, screen.width * 0.92),
          maxHeight: math.min(600, screen.height * 0.88),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutterLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Change PIN', style: AppTypography.headlineMd),
                const SizedBox(height: AppSpacing.lg),
                _pinField('Current PIN', _currentController, autofocus: true),
                const SizedBox(height: AppSpacing.md),
                _pinField('New PIN', _newController),
                const SizedBox(height: AppSpacing.md),
                _pinField('Confirm New PIN', _confirmController),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(label: 'Cancel', variant: AppButtonVariant.secondary, onPressed: Get.back),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: AppButton(label: 'Save', onPressed: _submit)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pinField(String label, TextEditingController controller, {bool autofocus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyMd),
        const SizedBox(height: AppSpacing.xs),
        PinDotsInput(controller: controller, onCompleted: (_) {}, autofocus: autofocus),
      ],
    );
  }
}