import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/setup_wizard_controller.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_shell.dart';
import '../widgets/pin_entry_step.dart';
import '../widgets/setup_details_step.dart';
import '../widgets/setup_step_dots.dart';

/// Runs exactly once per install, the first time the app opens with no
/// staff yet. Three steps, one split screen the whole time — the brand
/// panel shows the shop name live as it's typed, and never navigates away.
class SetupWizardScreen extends StatelessWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SetupWizardController>();

    return Obx(() {
      final brand = AuthBrandPanel(
        title: controller.liveShopName.value.isEmpty ? 'Your Shop' : controller.liveShopName.value,
        subtitle: 'Point of Sale',
      );

      switch (controller.step.value) {
        case SetupStep.details:
          return AuthShell(brand: brand, content: SetupDetailsStep(controller: controller));
        case SetupStep.createPin:
          return AuthShell(
            brand: brand,
            content: PinEntryStep(
              title: 'Create your PIN',
              subtitle: "You'll use this to log in every time.",
              leading: const SetupStepDots(total: 3, current: 1),
              pinController: controller.pinController,
              onCompleted: controller.onPinEntered,
            ),
          );
        case SetupStep.confirmPin:
          return AuthShell(
            brand: brand,
            content: PinEntryStep(
              title: 'Confirm your PIN',
              subtitle: 'Type it once more to make sure.',
              leading: const SetupStepDots(total: 3, current: 2),
              pinController: controller.confirmPinController,
              onCompleted: controller.onConfirmEntered,
              onBack: controller.backToCreatePin,
            ),
          );
      }
    });
  }
}