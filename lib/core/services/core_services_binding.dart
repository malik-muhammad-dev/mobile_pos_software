import 'package:get/get.dart';
import 'auth_service.dart';
import 'backup_service.dart';
import 'session_service.dart';
import 'shop_account_service.dart';
import 'shop_config_service.dart';
import 'subscription_service.dart';

/// App-wide singletons, registered once at startup — everything here uses
/// the real on-disk database (no databaseProvider override), matching the
/// TRD's Get.put(..., permanent: true) convention for services that must
/// outlive any single screen.
class CoreServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SessionService(), permanent: true);
    Get.put(SqliteAuthService(), permanent: true);
    Get.put(SqliteShopConfigService(), permanent: true);
    Get.put(BackupService(), permanent: true);
    // ShopAccountService must be registered before SubscriptionService —
    // SubscriptionService looks it up during its own startup.
    Get.put(ShopAccountService(), permanent: true);
    Get.put(SubscriptionService(), permanent: true);
  }
}