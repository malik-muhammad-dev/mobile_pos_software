import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/safe_submit.dart';
import '../../../../core/widgets/app_button.dart';

/// Attach a photo of the bank transfer / receipt and submit it for the
/// owner to review. Picks a real file from disk and uploads it to the
/// shop's own folder in Supabase Storage — see SubscriptionService.submitPayment.
class SubmitPaymentDialog extends StatefulWidget {
  const SubmitPaymentDialog({super.key});

  @override
  State<SubmitPaymentDialog> createState() => _SubmitPaymentDialogState();
}

class _SubmitPaymentDialogState extends State<SubmitPaymentDialog> {
  String? _pickedPath;
  String? _pickedName;
  String? _error;
  bool _isSubmitting = false;

  Future<void> _pickReceipt() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    setState(() {
      _pickedPath = file.path;
      _pickedName = file.name;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_pickedPath == null) {
      setState(() => _error = 'Attach a photo of the payment receipt first');
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    final ok = await safeSubmit(() async {
      await Get.find<SubscriptionService>().submitPayment(filePath: _pickedPath!);
      return true;
    });

    setState(() => _isSubmitting = false);

    if (ok == true) {
      Get.back();
      Get.snackbar(
        'Payment submitted',
        "We'll confirm once it's reviewed — usually within a day.",
        snackPosition: SnackPosition.BOTTOM,
      );
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
          maxWidth: math.min(420, screen.width * 0.92),
          maxHeight: math.min(560, screen.height * 0.88),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutterLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Submit Payment', style: AppTypography.headlineMd),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Send this month\'s subscription payment via bank transfer or '
                  'Easypaisa/JazzCash, then attach a photo of the receipt below.',
                  style: AppTypography.bodySm,
                ),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: _isSubmitting ? null : _pickReceipt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _pickedPath != null ? AppColors.primary : AppColors.borderDefault,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: _pickedPath != null ? AppColors.primary.withValues(alpha: 0.04) : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _pickedPath != null ? Icons.check_circle : Icons.add_a_photo_outlined,
                          size: 32,
                          color: _pickedPath != null ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _pickedName ?? 'Tap to attach receipt photo',
                          style: AppTypography.bodyMd,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.secondary,
                        onPressed: _isSubmitting ? null : Get.back,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: _isSubmitting ? 'Submitting...' : 'Submit',
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}