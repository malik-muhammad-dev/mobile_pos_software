import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/app_root/app_root_controller.dart';
import '../../../../core/services/shop_account_service.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/utils/safe_submit.dart';

enum ShopAccountMode { newShop, existingShop }

/// Drives the very first screen a brand-new install shows: register a new
/// shop, or log back into one that already exists — the reinstall / new-
/// machine path. See app_root.dart's cold-start ordering for why this is
/// separate from (and comes before) the local cashier PIN setup.
class ShopAccountController extends GetxController {
  final mode = ShopAccountMode.newShop.obs;
  final isSubmitting = false.obs;

  final shopNameController = TextEditingController();
  final phoneController = TextEditingController();
  final newEmailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final existingEmailController = TextEditingController();
  final existingPasswordController = TextEditingController();

  void setMode(ShopAccountMode value) => mode.value = value;

  void _showValidationMessage(String message) {
    Get.snackbar('', message, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
  }

  Future<void> submitNewShop() async {
    if (shopNameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
      _showValidationMessage('Please enter your shop name and phone number.');
      return;
    }
    if (newEmailController.text.trim().isEmpty) {
      _showValidationMessage('Please enter an email — you\'ll use it to log back in later.');
      return;
    }
    if (newPasswordController.text.length < 6) {
      _showValidationMessage('Password must be at least 6 characters.');
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      _showValidationMessage("Those passwords don't match — let's try again.");
      return;
    }

    isSubmitting.value = true;
    final ok = await safeSubmit(() async {
      await Get.find<ShopAccountService>().registerShop(
        shopName: shopNameController.text.trim(),
        phone: phoneController.text.trim(),
        email: newEmailController.text.trim(),
        password: newPasswordController.text,
      );
      return true;
    });
    isSubmitting.value = false;

    if (ok == true) {
      await Get.find<SubscriptionService>().refresh();
      await Get.find<AppRootController>().onShopAccountResolved();
    }
  }

  Future<void> submitExistingShop() async {
    if (existingEmailController.text.trim().isEmpty || existingPasswordController.text.isEmpty) {
      _showValidationMessage('Please enter your shop email and password.');
      return;
    }

    isSubmitting.value = true;
    final ok = await safeSubmit(() async {
      await Get.find<ShopAccountService>().reactivateShop(
        email: existingEmailController.text.trim(),
        password: existingPasswordController.text,
      );
      return true;
    });
    isSubmitting.value = false;

    if (ok == true) {
      await Get.find<SubscriptionService>().refresh();
      await Get.find<AppRootController>().onShopAccountResolved();
    }
  }

  @override
  void onClose() {
    shopNameController.dispose();
    phoneController.dispose();
    newEmailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    existingEmailController.dispose();
    existingPasswordController.dispose();
    super.onClose();
  }
}