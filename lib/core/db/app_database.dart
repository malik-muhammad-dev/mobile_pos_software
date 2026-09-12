import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'migrations/migration_v1.dart';

/// Owns the single on-disk SQLite database. Every Sqlite*Service/Repository
/// takes an optional `databaseProvider` override (see the testability note
/// on each service) so tests can inject an in-memory database instead of
/// touching this real one.
class AppDatabase {
  AppDatabase._();

  static const int schemaVersion = 1;
  static Database? _instance;

  static Future<Database> getDatabase() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationSupportDirectory();
    final dbPath = join(dir.path, 'mobile_shop_pos.db');
    _instance = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onCreate: (db, version) async => createV1Schema(db),
        onUpgrade: (db, oldVersion, newVersion) async {
          // Future migrations branch here, e.g.:
          // if (oldVersion < 2) { await createV2Migration(db); }
        },
      ),
    );
    return _instance!;
  }

  /// Test-only: open a throwaway in-memory database with the same schema.
  static Future<Database> openInMemoryForTest() async {
    return databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onCreate: (db, version) async => createV1Schema(db),
      ),
    );
  }
}