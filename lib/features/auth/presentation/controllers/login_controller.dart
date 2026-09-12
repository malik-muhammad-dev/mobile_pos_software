import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/shop_config_service.dart';
import '../../../../core/services/staff_model.dart';
import '../../../../core/utils/safe_submit.dart';

/// Every-day login: pick who you are from the active-staff list, then type
/// your PIN. Loads the shop name and staff list once on start.
class LoginController extends GetxController {
  final staffList = <Staff>[].obs;
  final selectedStaff = Rxn<Staff>();
  final shopName = ''.obs;
  final isLoading = true.obs;

  final pinController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadStaff();
  }

  /// Public so tests can await it directly instead of racing GetX's onInit
  /// timing; the real app just relies on onInit calling it once at start.
  Future<void> loadStaff() async {
    final config = await Get.find<SqliteShopConfigService>().getConfig();
    shopName.value = config?.shopName ?? 'Mobile Shop POS';

    final all = await Get.find<SqliteAuthService>().listStaff();
    staffList.assignAll(all.where((s) => s.active));
    isLoading.value = false;
  }

  void selectStaff(Staff staff) {
    pinController.clear();
    selectedStaff.value = staff;
  }

  void backToStaffList() {
    pinController.clear();
    selectedStaff.value = null;
  }

  Future<void> submitPin(String pin) async {
    final staff = selectedStaff.value;
    if (staff == null) return;

    final result = await safeSubmit(
      () => Get.find<SqliteAuthService>().login(staffId: staff.id, pin: pin),
    );

    if (result != null) {
      Get.find<SessionService>().logIn(result);
    } else {
      pinController.clear();
    }
  }

  @override
  void onClose() {
    pinController.dispose();
    super.onClose();
  }
}