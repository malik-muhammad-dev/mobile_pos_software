import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_shop_pos/core/db/app_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('v1 schema creates every expected table', () async {
    final db = await AppDatabase.openInMemoryForTest();
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    );
    final names = tables.map((row) => row['name'] as String).toSet();

    expect(names, containsAll([
      'shop_config',
      'staff',
      'iphone_products',
      'iphone_units',
      'android_products',
      'customers',
      'sales',
      'sale_items',
      'ledger_transactions',
      'stock_movements',
      'backups_log',
    ]));

    // Purchases/Vendors is cut from this build's scope — schema should not
    // silently grow tables nobody asked for.
    expect(names.contains('vendors'), isFalse);
    expect(names.contains('purchases'), isFalse);

    await db.close();
  });

  test('iphone_units rejects a duplicate IMEI at the schema level', () async {
    final db = await AppDatabase.openInMemoryForTest();
    final productId = await db.insert('iphone_products', {
      'model': 'iPhone 15 Pro',
      'storage': '256GB',
      'color': 'Natural Titanium',
      'condition': 'used_excellent',
      'cost_price': 360000,
      'sale_price': 395000,
    });

    await db.insert('iphone_units', {
      'product_id': productId,
      'imei': '354892019482710',
      'compliance_status': 'pta_approved',
      'status': 'in_stock',
    });

    expect(
      () => db.insert('iphone_units', {
        'product_id': productId,
        'imei': '354892019482710',
        'compliance_status': 'non_pta',
        'status': 'in_stock',
      }),
      throwsA(isA<Exception>()),
    );

    await db.close();
  });
}