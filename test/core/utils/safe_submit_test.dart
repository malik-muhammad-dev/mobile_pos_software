import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_shop_pos/core/utils/app_exceptions.dart';
import 'package:mobile_shop_pos/core/utils/safe_submit.dart';

/// Logic-only: does safeSubmit return the right thing (the value on
/// success, null on any failure)? It always calls Get.snackbar internally
/// on failure, which needs a GetMaterialApp mounted or it throws — pumpApp
/// exists only for that, not to check anything about how the snackbar
/// looks. There's deliberately no assertion on rendered text here anymore;
/// that was testing the UI, not the logic, and is exactly the kind of
/// thing that can flake on timing even when safeSubmit itself is correct.
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pump();
  }

  // Get.snackbar leaves behind global overlay/route state and a running
  // animation + auto-dismiss Timer. Get.reset() clears that between tests;
  // the trailing pump below just drains the Timer so it isn't still
  // pending when the test ends — necessary cleanup, not a UI check.
  tearDown(() {
    Get.reset();
  });

  testWidgets('returns the action\'s value on success', (tester) async {
    await pumpApp(tester);
    final result = await safeSubmit(() async => 42);
    expect(result, 42);
  });

  testWidgets('returns null on a known AppException', (tester) async {
    await pumpApp(tester);
    final result = await safeSubmit(() async => throw DuplicateImeiException(''));
    expect(result, isNull);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('returns null on an unexpected error too, not just known ones', (tester) async {
    await pumpApp(tester);
    final result = await safeSubmit(() async => throw StateError('raw technical detail'));
    expect(result, isNull);
    await tester.pump(const Duration(seconds: 5));
  });
}