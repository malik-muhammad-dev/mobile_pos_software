import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/setup_wizard_controller.dart';
import '../widgets/pin_entry_step.dart';
import '../widgets/setup_details_step.dart';

/// Runs exactly once per install, the first time the app opens with no
/// staff yet. Three steps: shop + owner name, create PIN, confirm PIN.
class SetupWizardScreen extends StatelessWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SetupWizardController>();

    return Obx(() {
      switch (controller.step.value) {
        case SetupStep.details:
          return SetupDetailsStep(controller: controller);
        case SetupStep.createPin:
          return PinEntryStep(
            title: 'Create your PIN',
            subtitle: "You'll use this to log in every time.",
            pinController: controller.pinController,
            onCompleted: controller.onPinEntered,
          );
        case SetupStep.confirmPin:
          return PinEntryStep(
            title: 'Confirm your PIN',
            subtitle: 'Type it once more to make sure.',
            pinController: controller.confirmPinController,
            onCompleted: controller.onConfirmEntered,
            onBack: controller.backToCreatePin,
          );
      }
    });
  }
}