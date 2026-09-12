import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_shop_pos/core/db/app_database.dart';
import 'package:mobile_shop_pos/core/services/auth_service.dart';
import 'package:mobile_shop_pos/core/services/session_service.dart';
import 'package:mobile_shop_pos/core/services/shop_config_service.dart';
import 'package:mobile_shop_pos/core/services/staff_model.dart';
import 'package:mobile_shop_pos/features/auth/presentation/controllers/login_controller.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pump();
  }

  late Database db;
  late SqliteAuthService authService;
  late LoginController controller;

  setUp(() async {
    db = await AppDatabase.openInMemoryForTest();
    authService = SqliteAuthService(databaseProvider: () async => db);
    Get.put(authService, permanent: true);
    Get.put(SqliteShopConfigService(databaseProvider: () async => db), permanent: true);
    Get.put(SessionService(), permanent: true);
    controller = LoginController();
  });

  // Each in-memory database goes through sqflite_common_ffi's shared native
  // worker — leaving them open across the whole test run lets connections
  // pile up and can stall later tests, so always close what was opened.
  tearDown(() async {
    Get.reset();
    await db.close();
  });

  // sqflite_common_ffi does its real work on a native worker, off the fake
  // clock testWidgets normally runs on — runAsync hands each of these
  // blocks the real event loop so those database awaits actually resolve
  // instead of hanging.

  testWidgets('loadStaff lists only active staff', (tester) async {
    await pumpApp(tester);
    await tester.runAsync(() async {
      await authService.createFirstOwner(name: 'Ahmed', pin: '1234');
      final cashier = await authService.addStaff(name: 'Hamza', pin: '5555', role: StaffRole.cashier);
      await authService.setActive(cashier.id, false);
      await controller.loadStaff();
    });

    expect(controller.staffList.map((s) => s.name), ['Ahmed']);
  });

  testWidgets('selectStaff sets the selection and clears the PIN field', (tester) async {
    await pumpApp(tester);
    late Staff owner;
    await tester.runAsync(() async {
      owner = await authService.createFirstOwner(name: 'Ahmed', pin: '1234');
    });
    controller.pinController.text = '99';

    controller.selectStaff(owner);

    expect(controller.selectedStaff.value?.id, owner.id);
    expect(controller.pinController.text, isEmpty);
  });

  testWidgets('submitPin logs in on the correct PIN', (tester) async {
    await pumpApp(tester);
    late Staff owner;
    await tester.runAsync(() async {
      owner = await authService.createFirstOwner(name: 'Ahmed', pin: '1234');
    });
    controller.selectStaff(owner);

    await tester.runAsync(() async {
      await controller.submitPin('1234');
    });

    final session = Get.find<SessionService>();
    expect(session.isLoggedIn, isTrue);
    expect(session.currentStaff.value?.id, owner.id);
  });

  testWidgets('submitPin clears the field and does not log in on a wrong PIN', (tester) async {
    await pumpApp(tester);
    late Staff owner;
    await tester.runAsync(() async {
      owner = await authService.createFirstOwner(name: 'Ahmed', pin: '1234');
    });
    controller.selectStaff(owner);

    await tester.runAsync(() async {
      await controller.submitPin('0000');
    });
    await tester.pump();

    expect(Get.find<SessionService>().isLoggedIn, isFalse);
    expect(controller.pinController.text, isEmpty);
    await tester.pump(const Duration(seconds: 5));
  });
}