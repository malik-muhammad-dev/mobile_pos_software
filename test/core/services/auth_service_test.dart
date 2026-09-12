import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_shop_pos/core/db/app_database.dart';
import 'package:mobile_shop_pos/core/services/auth_service.dart';
import 'package:mobile_shop_pos/core/services/staff_model.dart';
import 'package:mobile_shop_pos/core/utils/app_exceptions.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late SqliteAuthService authService;

  setUp(() async {
    final db = await AppDatabase.openInMemoryForTest();
    authService = SqliteAuthService(databaseProvider: () async => db);
  });

  test('hasAnyStaff is false before setup, true after', () async {
    expect(await authService.hasAnyStaff(), isFalse);
    await authService.createFirstOwner(name: 'Babar Azam', pin: '1234');
    expect(await authService.hasAnyStaff(), isTrue);
  });

  test('login succeeds with the correct PIN and returns the Owner role', () async {
    final owner = await authService.createFirstOwner(name: 'Babar Azam', pin: '1234');
    final loggedIn = await authService.login(staffId: owner.id, pin: '1234');
    expect(loggedIn.role, StaffRole.owner);
  });

  test('login throws InvalidPinException on a wrong PIN', () async {
    final owner = await authService.createFirstOwner(name: 'Babar Azam', pin: '1234');
    expect(
      () => authService.login(staffId: owner.id, pin: '0000'),
      throwsA(isA<InvalidPinException>()),
    );
  });

  test('login throws AccountDeactivatedException for a deactivated staff member', () async {
    final cashier = await authService.addStaff(name: 'Hamza', pin: '5555', role: StaffRole.cashier);
    await authService.setActive(cashier.id, false);
    expect(
      () => authService.login(staffId: cashier.id, pin: '5555'),
      throwsA(isA<AccountDeactivatedException>()),
    );
  });

  test('resetPin invalidates the old PIN and accepts the new one', () async {
    final cashier = await authService.addStaff(name: 'Hamza', pin: '5555', role: StaffRole.cashier);
    await authService.resetPin(cashier.id, '9999');

    expect(
      () => authService.login(staffId: cashier.id, pin: '5555'),
      throwsA(isA<InvalidPinException>()),
    );
    final loggedIn = await authService.login(staffId: cashier.id, pin: '9999');
    expect(loggedIn.id, cashier.id);
  });
}