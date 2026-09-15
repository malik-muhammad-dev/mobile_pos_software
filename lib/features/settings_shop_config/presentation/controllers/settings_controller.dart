import 'package:get/get.dart';

/// Mirrors backups_log.type — 'auto' runs in the background on its own
/// schedule, 'manual' is triggered by Backup Now.
enum BackupType { auto, manual }

extension BackupTypeX on BackupType {
  String get label => this == BackupType.auto ? 'Automatic' : 'Manual';
}

class SampleBackupEntry {
  const SampleBackupEntry({required this.dateTime, required this.type, required this.sizeBytes});

  final DateTime dateTime;
  final BackupType type;
  final int sizeBytes;
}

/// Settings screen state (Owner-only). Placeholder-only, per the UI-first
/// build order — shop profile fields and the backup list are sample data
/// so the screen can be reviewed before it's wired to the real shop_config
/// / backups_log tables. No staff-management screen here on purpose — cut
/// from this build's scope; "My Account" only covers the logged-in
/// owner's own PIN, not a staff list.
class SettingsController extends GetxController {
  final RxString shopName = 'Al-Karam Mobiles'.obs;
  final RxString address = 'Commercial Market, Mianwali'.obs;
  final RxInt lowStockThreshold = 3.obs;

  final RxList<SampleBackupEntry> backups = <SampleBackupEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    backups.assignAll([
      SampleBackupEntry(dateTime: now.subtract(const Duration(hours: 6)), type: BackupType.auto, sizeBytes: 482000),
      SampleBackupEntry(dateTime: now.subtract(const Duration(days: 1, hours: 6)), type: BackupType.auto, sizeBytes: 478000),
      SampleBackupEntry(dateTime: now.subtract(const Duration(days: 2, hours: 6)), type: BackupType.auto, sizeBytes: 471000),
      SampleBackupEntry(dateTime: now.subtract(const Duration(days: 3)), type: BackupType.manual, sizeBytes: 465000),
    ]);
  }

  DateTime? get lastBackupAt => backups.isEmpty ? null : backups.first.dateTime;

  /// Demo-only: appends a sample row. No real file is written yet — exists
  /// so Backup Now can be shown working before the real backup job (and
  /// backups_log write) is wired in.
  void backupNow() {
    backups.insert(
      0,
      SampleBackupEntry(dateTime: DateTime.now(), type: BackupType.manual, sizeBytes: 483000 + backups.length * 400),
    );
  }

  /// Demo-only: updates the in-memory sample values and nothing else yet —
  /// no real shop_config row to write to until the database is wired up.
  void saveShopProfile({required String name, required String shopAddress, required int threshold}) {
    shopName.value = name;
    address.value = shopAddress;
    lowStockThreshold.value = threshold;
  }
}