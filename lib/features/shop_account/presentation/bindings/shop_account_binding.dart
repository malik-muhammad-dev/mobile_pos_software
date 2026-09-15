import 'package:get/get.dart';
import '../controllers/shop_account_controller.dart';

/// Registered once at startup alongside CoreServicesBinding — lazy + fenix
/// so this is only actually built the first time ShopAccountScreen needs
/// it, matching AuthBinding's pattern.
class ShopAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShopAccountController(), fenix: true);
  }
}