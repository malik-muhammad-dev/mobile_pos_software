import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../db/app_database.dart';
import '../utils/app_exceptions.dart';
import '../utils/pin_hash.dart';
import 'staff_model.dart';

/// Handles staff login, first-run Owner creation, and staff lifecycle.
/// Takes an optional databaseProvider — the one testability seam every
/// data-layer class in this app follows — so tests inject an in-memory
/// database instead of the real on-disk one.
class SqliteAuthService {
  SqliteAuthService({Future<Database> Function()? databaseProvider})
      : _databaseProvider = databaseProvider ?? AppDatabase.getDatabase;

  final Future<Database> Function() _databaseProvider;

  Future<bool> hasAnyStaff() async {
    final db = await _databaseProvider();
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM staff');
    return (result.first['c'] as int) > 0;
  }

  /// First-run Setup Wizard: creates the very first Owner account.
  Future<Staff> createFirstOwner({required String name, required String pin}) async {
    final db = await _databaseProvider();
    final id = await db.insert('staff', {
      'name': name,
      'pin_hash': PinHash.hash(pin),
      'role': 'owner',
      'active': 1,
    });
    return Staff(id: id, name: name, role: StaffRole.owner, active: true);
  }

  Future<Staff> addStaff({
    required String name,
    required String pin,
    required StaffRole role,
  }) async {
    final db = await _databaseProvider();
    final id = await db.insert('staff', {
      'name': name,
      'pin_hash': PinHash.hash(pin),
      'role': staffRoleToDb(role),
      'active': 1,
    });
    return Staff(id: id, name: name, role: role, active: true);
  }

  Future<void> setActive(int staffId, bool active) async {
    final db = await _databaseProvider();
    await db.update('staff', {'active': active ? 1 : 0},
        where: 'id = ?', whereArgs: [staffId]);
  }

  Future<void> resetPin(int staffId, String newPin) async {
    final db = await _databaseProvider();
    await db.update('staff', {'pin_hash': PinHash.hash(newPin)},
        where: 'id = ?', whereArgs: [staffId]);
  }

  Future<List<Staff>> listStaff() async {
    final db = await _databaseProvider();
    final rows = await db.query('staff', orderBy: 'name');
    return rows.map(Staff.fromRow).toList();
  }

  /// Throws InvalidPinException or AccountDeactivatedException on failure —
  /// safeSubmit turns those straight into the plain-language messages the
  /// PRD requires on the login screen.
  Future<Staff> login({required int staffId, required String pin}) async {
    final db = await _databaseProvider();
    final rows = await db.query('staff', where: 'id = ?', whereArgs: [staffId]);
    if (rows.isEmpty) throw const InvalidPinException();

    final row = rows.first;
    final active = (row['active'] as int) == 1;
    if (!active) throw const AccountDeactivatedException();

    final storedHash = row['pin_hash'] as String;
    if (!PinHash.verify(pin, storedHash)) throw const InvalidPinException();

    return Staff.fromRow(row);
  }
}