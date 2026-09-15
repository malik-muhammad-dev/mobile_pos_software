import 'package:get/get.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/shop_config_service.dart';
import '../../../../core/utils/safe_submit.dart';

/// Settings screen state (Owner-only). Unlike most of this app's other
/// screens, this one is wired to the real data layer already — Setup
/// Wizard writes shop_config for real on first run via
/// SqliteShopConfigService, and BackupService already copies the real .db
/// file and logs it — so there was no reason to sit this behind sample
/// data too. No staff-management here on purpose (cut from this build's
/// scope); "My Account" only covers the logged-in owner's own PIN.
class SettingsController extends GetxController {
  final SqliteShopConfigService _shopConfigService = Get.find<SqliteShopConfigService>();
  final BackupService _backupService = Get.find<BackupService>();

  final RxBool isLoading = true.obs;

  final RxString shopName = ''.obs;
  final RxString address = ''.obs;
  final RxInt lowStockThreshold = 3.obs;

  final RxList<BackupRecord> backups = <BackupRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final config = await _shopConfigService.getConfig();
    if (config != null) {
      shopName.value = config.shopName;
      address.value = config.address ?? '';
      lowStockThreshold.value = config.lowStockThreshold;
    }
    backups.assignAll(await _backupService.recentBackups());
    isLoading.value = false;
  }

  BackupRecord? get lastBackup => backups.isEmpty ? null : backups.first;

  Future<void> backupNow() async {
    final record = await safeSubmit(() => _backupService.runBackup(manual: true));
    if (record != null) {
      backups.insert(0, record);
    }
  }

  Future<void> saveShopProfile({required String name, required String shopAddress, required int threshold}) async {
    final saved = await safeSubmit(() async {
      await _shopConfigService.saveConfig(
        shopName: name,
        address: shopAddress.isEmpty ? null : shopAddress,
        lowStockThreshold: threshold,
      );
      return true;
    });
    if (saved == true) {
      shopName.value = name;
      address.value = shopAddress;
      lowStockThreshold.value = threshold;
      Get.snackbar('Saved', 'Shop profile updated.', snackPosition: SnackPosition.BOTTOM);
    }
  }
}