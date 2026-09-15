import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Schema v2 — adds local caching for the cloud subscription/licensing
/// system. shop_license is a single row (id = 1), same pattern as
/// shop_config: the last-known-good subscription state, refreshed from
/// Supabase when online, and read from when offline (that's the whole
/// point — the desktop app must never block on a network call just to
/// enforce its own lock screen).
Future<void> createV2Migration(Database db) async {
  await db.execute('''
    CREATE TABLE shop_license (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      shop_id TEXT,
      status TEXT,
      next_due_date TEXT,
      grace_end_date TEXT,
      payment_pending_review INTEGER NOT NULL DEFAULT 0,
      last_checked_at TEXT
    )
  ''');
}