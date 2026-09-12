import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_shop_pos/core/db/app_database.dart';
import 'package:mobile_shop_pos/core/services/auth_service.dart';
import 'package:mobile_shop_pos/core/services/session_service.dart';
import 'package:mobile_shop_pos/core/services/shop_config_service.dart';
import 'package:mobile_shop_pos/core/services/staff_model.dart';
import 'package:mobile_shop_pos/features/auth/presentation/controllers/setup_wizard_controller.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pump();
  }

  late SetupWizardController controller;

  setUp(() async {
    final db = await AppDatabase.openInMemoryForTest();
    Get.put(SqliteAuthService(databaseProvider: () async => db), permanent: true);
    Get.put(SqliteShopConfigService(databaseProvider: () async => db), permanent: true);
    Get.put(SessionService(), permanent: true);
    controller = SetupWizardController();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('submitDetails does not advance when a name is missing', (tester) async {
    await pumpApp(tester);
    controller.submitDetails();
    expect(controller.step.value, SetupStep.details);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('submitDetails advances to createPin once both names are filled in', (tester) async {
    await pumpApp(tester);
    controller.shopNameController.text = 'Al-Karam Mobiles';
    controller.ownerNameController.text = 'Ahmed';
    controller.submitDetails();
    expect(controller.step.value, SetupStep.createPin);
  });

  testWidgets('onPinEntered advances from createPin to confirmPin', (tester) async {
    await pumpApp(tester);
    controller.step.value = SetupStep.createPin;
    controller.onPinEntered('1234');
    expect(controller.step.value, SetupStep.confirmPin);
  });

  testWidgets('mismatched confirm PIN sends the user back to createPin, cleared', (tester) async {
    await pumpApp(tester);
    controller.shopNameController.text = 'Al-Karam Mobiles';
    controller.ownerNameController.text = 'Ahmed';
    controller.pinController.text = '1234';
    controller.step.value = SetupStep.confirmPin;

    await controller.onConfirmEntered('9999');
    await tester.pump();

    expect(controller.step.value, SetupStep.createPin);
    expect(controller.pinController.text, isEmpty);
    expect(Get.find<SessionService>().isLoggedIn, isFalse);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('matching PIN creates the owner, saves shop config, and logs them in', (tester) async {
    await pumpApp(tester);
    controller.shopNameController.text = 'Al-Karam Mobiles';
    controller.ownerNameController.text = 'Ahmed';
    controller.pinController.text = '1234';
    controller.step.value = SetupStep.confirmPin;

    await controller.onConfirmEntered('1234');

    final session = Get.find<SessionService>();
    expect(session.isLoggedIn, isTrue);
    expect(session.currentStaff.value?.name, 'Ahmed');
    expect(session.currentStaff.value?.role, StaffRole.owner);

    final config = await Get.find<SqliteShopConfigService>().getConfig();
    expect(config?.shopName, 'Al-Karam Mobiles');
  });
}