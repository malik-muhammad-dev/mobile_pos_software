import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_shop_pos/core/utils/app_exceptions.dart';
import 'package:mobile_shop_pos/core/utils/safe_submit.dart';

void main() {
  // safeSubmit shows a Get.snackbar on failure, which needs a
  // GetMaterialApp's overlay mounted first.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pump();
  }

  // Get.snackbar leaves behind global overlay/route state and a running
  // animation + auto-dismiss Timer. Without resetting between tests, the
  // second snackbar-triggering test collides with leftovers from the first
  // (duplicate GlobalKeys, "deactivated widget" lookups). Get.reset() clears
  // that global state so every test starts clean.
  tearDown(() {
    Get.reset();
  });

  testWidgets('returns the action\'s value on success', (tester) async {
    await pumpApp(tester);
    final result = await safeSubmit(() async => 42);
    expect(result, 42);
  });

  testWidgets('returns null and shows the AppException message on a known failure', (tester) async {
    await pumpApp(tester);
    final result = await safeSubmit(() async => throw DuplicateImeiException(''));
    expect(result, isNull);
    await tester.pump();
    expect(find.textContaining('already in the system'), findsOneWidget);
    // Drain the snackbar's show animation + its 4-second auto-dismiss Timer
    // so nothing is still pending when the test ends.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('returns null and shows the calm fallback on an unexpected error', (tester) async {
    await pumpApp(tester);
    final result = await safeSubmit(() async => throw StateError('raw technical detail'));
    expect(result, isNull);
    await tester.pump();
    // The raw error text must never reach the screen — only the fallback.
    expect(find.textContaining('raw technical detail'), findsNothing);
    expect(find.textContaining('Something went wrong'), findsOneWidget);
    // Drain the snackbar's show animation + its 4-second auto-dismiss Timer
    // so nothing is still pending when the test ends.
    await tester.pump(const Duration(seconds: 5));
  });
}