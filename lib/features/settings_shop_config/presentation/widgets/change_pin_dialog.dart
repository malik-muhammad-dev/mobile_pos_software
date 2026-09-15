import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_exceptions.dart';
import '../../../../core/utils/safe_submit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/widgets/pin_dots_input.dart';

/// Change the logged-in owner's PIN — wired to the real SqliteAuthService:
/// current PIN is checked with the same login() staff/PIN verification the
/// login screen uses, then resetPin() writes the new pin_hash for real.
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

  Future<void> _submit() async {
    if (_currentController.text.length != 4) {
      setState(() => _error = 'Enter your current PIN');
      return;
    }
    if (_newController.text.length != 4) {
      setState(() => _error = 'New PIN must be 4 digits');
      return;
    }

    final staffId = Get.find<SessionService>().currentStaff.value?.id;
    if (staffId == null) {
      setState(() => _error = "Session expired — please log back in.");
      return;
    }

    setState(() => _error = null);
    final authService = Get.find<SqliteAuthService>();

    final ok = await safeSubmit(() async {
      // Reuses the exact same PIN check the login screen makes — wrong
      // current PIN throws InvalidPinException, same message either place.
      await authService.login(staffId: staffId, pin: _currentController.text);
      if (_newController.text != _confirmController.text) {
        throw const PinMismatchException();
      }
      await authService.resetPin(staffId, _newController.text);
      return true;
    });

    if (ok == true) {
      Get.back();
      Get.snackbar('PIN updated', 'Your PIN has been changed.', snackPosition: SnackPosition.BOTTOM);
    }
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