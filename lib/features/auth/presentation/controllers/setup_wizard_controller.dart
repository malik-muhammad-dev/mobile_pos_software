import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/shop_config_service.dart';
import '../../../../core/utils/app_exceptions.dart';
import '../../../../core/utils/safe_submit.dart';

enum SetupStep { details, createPin, confirmPin }

/// Drives the one-time first-run setup: shop name + owner's name, then
/// create-PIN, then confirm-PIN. On success this logs the new Owner
/// straight in — AppRoot switches to the AppShell on its own once
/// SessionService reports someone logged in.
class SetupWizardController extends GetxController {
  final step = SetupStep.details.obs;
  final isSubmitting = false.obs;

  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  void submitDetails() {
    if (shopNameController.text.trim().isEmpty || ownerNameController.text.trim().isEmpty) {
      Get.snackbar('', 'Please enter your shop name and your name.',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }
    step.value = SetupStep.createPin;
  }

  void onPinEntered(String pin) {
    step.value = SetupStep.confirmPin;
  }

  void backToCreatePin() {
    pinController.clear();
    confirmPinController.clear();
    step.value = SetupStep.createPin;
  }

  Future<void> onConfirmEntered(String confirmPin) async {
    isSubmitting.value = true;
    final staff = await safeSubmit(() async {
      if (confirmPin != pinController.text) {
        throw const PinMismatchException();
      }
      await Get.find<SqliteShopConfigService>().saveConfig(
        shopName: shopNameController.text.trim(),
      );
      return Get.find<SqliteAuthService>().createFirstOwner(
        name: ownerNameController.text.trim(),
        pin: confirmPin,
      );
    });
    isSubmitting.value = false;

    if (staff != null) {
      Get.find<SessionService>().logIn(staff);
    } else {
      backToCreatePin();
    }
  }

  @override
  void onClose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    pinController.dispose();
    confirmPinController.dispose();
    super.onClose();
  }
}