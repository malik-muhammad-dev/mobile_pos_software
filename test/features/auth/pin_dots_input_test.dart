import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shop_pos/features/auth/presentation/widgets/pin_dots_input.dart';

void main() {
  testWidgets('calls onCompleted once the field reaches its length', (tester) async {
    final controller = TextEditingController();
    final results = <String>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PinDotsInput(controller: controller, onCompleted: results.add)),
    ));

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();

    expect(results, ['1234']);
  });

  testWidgets('keeps responding after being rebuilt with a different controller', (tester) async {
    // Setup Wizard reuses this exact widget slot for create-PIN then
    // confirm-PIN, just handing it a different controller — this is the
    // scenario that silently stopped working before didUpdateWidget moved
    // the listener over.
    final controllerA = TextEditingController();
    final controllerB = TextEditingController();
    final results = <String>[];

    Widget build(TextEditingController controller) => MaterialApp(
          home: Scaffold(body: PinDotsInput(controller: controller, onCompleted: results.add)),
        );

    await tester.pumpWidget(build(controllerA));
    await tester.enterText(find.byType(TextField), '1111');
    await tester.pump();
    expect(results, ['1111']);

    await tester.pumpWidget(build(controllerB));
    await tester.enterText(find.byType(TextField), '2222');
    await tester.pump();

    expect(results, ['1111', '2222']);
  });
}