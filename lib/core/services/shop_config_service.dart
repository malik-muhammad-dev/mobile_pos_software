import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../db/app_database.dart';

class ShopConfig {
  final String shopName;
  final String? address;
  final String? logoPath;
  final String currency;
  final int lowStockThreshold;

  const ShopConfig({
    required this.shopName,
    this.address,
    this.logoPath,
    required this.currency,
    required this.lowStockThreshold,
  });

  factory ShopConfig.fromRow(Map<String, Object?> row) => ShopConfig(
        shopName: row['shop_name'] as String,
        address: row['address'] as String?,
        logoPath: row['logo_path'] as String?,
        currency: row['currency'] as String,
        lowStockThreshold: row['low_stock_threshold'] as int,
      );
}

/// White-labeling lives entirely here: shop_config is a single row (id = 1),
/// never a hardcoded value anywhere else in the app.
class SqliteShopConfigService {
  SqliteShopConfigService({Future<Database> Function()? databaseProvider})
      : _databaseProvider = databaseProvider ?? AppDatabase.getDatabase;

  final Future<Database> Function() _databaseProvider;

  Future<ShopConfig?> getConfig() async {
    final db = await _databaseProvider();
    final rows = await db.query('shop_config', where: 'id = 1');
    if (rows.isEmpty) return null;
    return ShopConfig.fromRow(rows.first);
  }

  /// Setup Wizard step 1 and later Settings edits both call this — upsert
  /// keeps it a single row either way.
  Future<void> saveConfig({
    required String shopName,
    String? address,
    String? logoPath,
    String currency = 'PKR',
    int lowStockThreshold = 3,
  }) async {
    final db = await _databaseProvider();
    await db.insert(
      'shop_config',
      {
        'id': 1,
        'shop_name': shopName,
        'address': address,
        'logo_path': logoPath,
        'currency': currency,
        'low_stock_threshold': lowStockThreshold,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}