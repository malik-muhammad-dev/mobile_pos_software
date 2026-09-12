import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_shop_pos/core/app_root/app_root_controller.dart';
import 'package:mobile_shop_pos/core/db/app_database.dart';
import 'package:mobile_shop_pos/core/services/auth_service.dart';
import 'package:mobile_shop_pos/core/services/session_service.dart';
import 'package:mobile_shop_pos/core/services/staff_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pump();
  }

  late Database db;

  tearDown(() async {
    Get.reset();
    await db.close();
  });

  testWidgets('resolves to needsSetup when no staff exist yet', (tester) async {
    await pumpApp(tester);
    db = await AppDatabase.openInMemoryForTest();
    Get.put(SqliteAuthService(databaseProvider: () async => db), permanent: true);
    Get.put(SessionService(), permanent: true);

    late AppRootController controller;
    await tester.runAsync(() async {
      controller = Get.put(AppRootController());
      await Future<void>.delayed(const Duration(milliseconds: 700));
    });

    expect(controller.state.value, ColdStartState.needsSetup);
  });

  testWidgets('resolves to needsLogin when staff already exist', (tester) async {
    await pumpApp(tester);
    db = await AppDatabase.openInMemoryForTest();
    final authService = SqliteAuthService(databaseProvider: () async => db);
    await authService.createFirstOwner(name: 'Ahmed', pin: '1234');
    Get.put(authService, permanent: true);
    Get.put(SessionService(), permanent: true);

    late AppRootController controller;
    await tester.runAsync(() async {
      controller = Get.put(AppRootController());
      await Future<void>.delayed(const Duration(milliseconds: 700));
    });

    expect(controller.state.value, ColdStartState.needsLogin);
  });

  testWidgets('logging out after being logged in lands on needsLogin, never stale setup state', (tester) async {
    await pumpApp(tester);
    db = await AppDatabase.openInMemoryForTest();
    Get.put(SqliteAuthService(databaseProvider: () async => db), permanent: true);
    final session = Get.put(SessionService(), permanent: true);

    // A brand new install starts out needing setup...
    late AppRootController controller;
    await tester.runAsync(() async {
      controller = Get.put(AppRootController());
      await Future<void>.delayed(const Duration(milliseconds: 700));
    });
    expect(controller.state.value, ColdStartState.needsSetup);

    // ...Setup Wizard finishes and logs the new owner in...
    session.logIn(const Staff(id: 1, name: 'Ahmed', role: StaffRole.owner, active: true));
    // ...then later, at the end of a shift, they log out.
    session.logOut();
    await tester.pump();

    expect(controller.state.value, ColdStartState.needsLogin);
  });
}