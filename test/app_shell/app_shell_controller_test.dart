import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shop_pos/core/app_shell/app_shell_controller.dart';
import 'package:mobile_shop_pos/core/services/staff_model.dart';

void main() {
  late AppShellController controller;

  setUp(() => controller = AppShellController());

  test('Owner sees every module, including Inventory/Reports/Settings', () {
    final ids = controller.itemsFor(StaffRole.owner).map((item) => item.id).toList();
    expect(ids, containsAll(['sales', 'inventory', 'customers_ledger', 'reports', 'settings']));
    // A Cashier-hidden feature must be genuinely absent, not disabled —
    // Owner nav shouldn't carry the Cashier's separate stock-lookup entry.
    expect(ids.contains('stock_lookup'), isFalse);
  });

  test('Cashier nav genuinely excludes cost/margin-adjacent modules', () {
    final ids = controller.itemsFor(StaffRole.cashier).map((item) => item.id).toList();
    expect(ids, containsAll(['sales', 'stock_lookup', 'customers_ledger']));
    expect(ids.contains('inventory'), isFalse);
    expect(ids.contains('reports'), isFalse);
    expect(ids.contains('settings'), isFalse);
  });
}