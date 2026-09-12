import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Schema v1. Once this ships to a real shop, these CREATE TABLE statements
/// are never edited in place — a future change is migration_v2.dart plus a
/// schemaVersion bump and an onUpgrade branch. Purchases/Vendors tables are
/// intentionally NOT included — that module is cut from this build; add
/// them back via a later migration if it returns to scope.
Future<void> createV1Schema(Database db) async {
  await db.execute('''
    CREATE TABLE shop_config (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      shop_name TEXT NOT NULL,
      address TEXT,
      logo_path TEXT,
      currency TEXT NOT NULL DEFAULT 'PKR',
      low_stock_threshold INTEGER NOT NULL DEFAULT 3
    )
  ''');

  await db.execute('''
    CREATE TABLE staff (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      pin_hash TEXT NOT NULL,
      role TEXT NOT NULL CHECK (role IN ('owner', 'cashier')),
      active INTEGER NOT NULL DEFAULT 1
    )
  ''');

  await db.execute('''
    CREATE TABLE iphone_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      model TEXT NOT NULL,
      storage TEXT NOT NULL,
      color TEXT NOT NULL,
      condition TEXT NOT NULL CHECK (
        condition IN ('new', 'used_excellent', 'used_good', 'used_fair')
      ),
      cost_price INTEGER NOT NULL,
      sale_price INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE iphone_units (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL REFERENCES iphone_products(id),
      imei TEXT NOT NULL UNIQUE,
      compliance_status TEXT NOT NULL CHECK (
        compliance_status IN ('pta_approved', 'non_pta', 'jv', 'mdm', 'factory_unlocked')
      ),
      battery_health INTEGER,
      status TEXT NOT NULL DEFAULT 'in_stock' CHECK (
        status IN ('in_stock', 'sold', 'reserved')
      )
    )
  ''');

  await db.execute('''
    CREATE TABLE android_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      brand TEXT NOT NULL,
      model TEXT NOT NULL,
      storage TEXT,
      ram TEXT,
      color TEXT,
      condition TEXT NOT NULL CHECK (condition IN ('new', 'used')),
      quantity INTEGER NOT NULL DEFAULT 0,
      imei TEXT,
      cost_price INTEGER NOT NULL,
      sale_price INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE customers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      cnic TEXT,
      credit_limit INTEGER
    )
  ''');

  await db.execute('''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_no TEXT NOT NULL UNIQUE,
      cashier_id INTEGER NOT NULL REFERENCES staff(id),
      customer_id INTEGER REFERENCES customers(id),
      subtotal INTEGER NOT NULL,
      discount INTEGER NOT NULL DEFAULT 0,
      total INTEGER NOT NULL,
      payment_method TEXT NOT NULL CHECK (
        payment_method IN ('cash', 'card', 'bank', 'partial_credit')
      ),
      amount_paid INTEGER NOT NULL,
      balance_due INTEGER NOT NULL DEFAULT 0,
      voided INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE sale_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER NOT NULL REFERENCES sales(id),
      unit_id INTEGER REFERENCES iphone_units(id),
      description TEXT NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 1,
      unit_price INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE ledger_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id),
      type TEXT NOT NULL CHECK (type IN ('charge', 'payment')),
      amount INTEGER NOT NULL,
      sale_id INTEGER REFERENCES sales(id),
      created_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE stock_movements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ref_type TEXT NOT NULL CHECK (ref_type IN ('iphone_unit', 'android_product')),
      ref_id INTEGER NOT NULL,
      movement_type TEXT NOT NULL CHECK (
        movement_type IN ('received', 'sold', 'adjusted', 'returned')
      ),
      staff_id INTEGER NOT NULL REFERENCES staff(id),
      created_at TEXT NOT NULL,
      note TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE backups_log (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_at TEXT NOT NULL,
      file_path TEXT NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('auto', 'manual')),
      size_bytes INTEGER NOT NULL
    )
  ''');
}