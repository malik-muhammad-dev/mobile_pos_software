import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/setup_wizard_controller.dart';
import 'auth_scaffold.dart';

/// First-run step 1: shop name + owner's own name. Runs exactly once per
/// install — the closest thing this app has to a "sign up".
class SetupDetailsStep extends StatelessWidget {
  const SetupDetailsStep({super.key, required this.controller});

  final SetupWizardController controller;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome',
      subtitle: "Let's set up your shop.",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: controller.shopNameController,
            label: 'Shop name',
            hint: 'e.g. Al-Karam Mobiles',
            autofocus: true,
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
      ),
    );
  }
}