import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/setup_wizard_controller.dart';
import 'setup_step_dots.dart';

/// First-run step 1: shop name + owner's own name. Runs exactly once per
/// install — the closest thing this app has to a "sign up". The shop name
/// mirrors live onto the brand panel as it's typed.
class SetupDetailsStep extends StatelessWidget {
  const SetupDetailsStep({super.key, required this.controller});

  final SetupWizardController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SetupStepDots(total: 3, current: 0),
        const SizedBox(height: AppSpacing.lg),
        const Text("Let's set up your shop", style: AppTypography.headlineLg),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          controller: controller.shopNameController,
          label: 'Shop name',
          hint: 'e.g. Al-Karam Mobiles',
          autofocus: true,
          onChanged: (value) => controller.liveShopName.value = value,
        ),
        const SizedBox(height: AppSpacing.gutter),
        AppTextField(
          controller: controller.ownerNameController,
          label: 'Your name',
          hint: 'e.g. Ahmed',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(label: 'Continue', onPressed: controller.submitDetails),
      ],
    );
  }
}