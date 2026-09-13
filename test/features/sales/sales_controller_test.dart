import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_shop_pos/core/services/session_service.dart';
import 'package:mobile_shop_pos/features/inventory/presentations/controllers/inventory_controller.dart';
import 'package:mobile_shop_pos/features/sales/presentation/controllers/sales_controller.dart';

/// Logic-only coverage for Sales — no widgets pumped, no UI asserted. Just
/// the calculations (net price, balance/Udhar) and the bookkeeping
/// addSale does against Inventory. Deliberately leaves out anything to do
/// with rendering, since that's the kind of test that can flake even when
/// the app itself is working fine.
void main() {
  late SalesController sales;
  late InventoryController inventory;

  setUp(() {
    Get.put(SessionService(), permanent: true);
    inventory = Get.put(InventoryController(), permanent: true);
    sales = Get.put(SalesController(), permanent: true);
  });

  tearDown(() => Get.reset());

  group('SampleSaleEntry math', () {
    test('netPrice subtracts the discount from price', () {
      const entry = SampleSaleEntry(
        time: '', customerName: '', itemDescription: '',
        price: 40000, discount: 5000, amountPaid: 35000,
      );
      expect(entry.netPrice, 35000);
    });

    test('netPrice never goes below zero even if discount exceeds price', () {
      const entry = SampleSaleEntry(
        time: '', customerName: '', itemDescription: '',
        price: 10000, discount: 50000, amountPaid: 0,
      );
      expect(entry.netPrice, 0);
    });

    test('balanceDue is netPrice minus amountPaid, clamped at zero', () {
      const fullyPaid = SampleSaleEntry(
        time: '', customerName: '', itemDescription: '',
        price: 40000, amountPaid: 40000,
      );
      const overpaid = SampleSaleEntry(
        time: '', customerName: '', itemDescription: '',
        price: 40000, amountPaid: 50000,
      );
      const partialAfterDiscount = SampleSaleEntry(
        time: '', customerName: '', itemDescription: '',
        price: 40000, discount: 4000, amountPaid: 20000,
      );

      expect(fullyPaid.balanceDue, 0);
      expect(overpaid.balanceDue, 0);
      // net = 40000 - 4000 = 36000; balance = 36000 - 20000
      expect(partialAfterDiscount.balanceDue, 16000);
    });

    test('isUdhar and hasDiscount reflect balanceDue/discount', () {
      const fullyPaidNoDiscount = SampleSaleEntry(
        time: '', customerName: '', itemDescription: '',
        price: 1000, amountPaid: 1000,
      );
      const partialWithDiscount = SampleSaleEntry(
        time: '', customerName: '', itemDescription: '',
        price: 1000, discount: 100, amountPaid: 500,
      );

      expect(fullyPaidNoDiscount.isUdhar, isFalse);
      expect(fullyPaidNoDiscount.hasDiscount, isFalse);
      expect(partialWithDiscount.isUdhar, isTrue);
      expect(partialWithDiscount.hasDiscount, isTrue);
    });
  });

  group('SalesController.addSale', () {
    test('inserts the new entry at the top and returns matching receipt data', () {
      final before = sales.recentSales.length;
      final receipt = sales.addSale(
        customerName: 'Test Customer',
        itemDescription: 'Custom accessory',
        price: 5000,
        amountPaid: 5000,
      );

      expect(sales.recentSales.length, before + 1);
      expect(sales.recentSales.first.customerName, 'Test Customer');
      expect(receipt.price, 5000);
      expect(receipt.amountPaid, 5000);
      expect(receipt.isFullyPaid, isTrue);
    });

    test('a blank customer name resolves to Walk-in Customer', () {
      final receipt = sales.addSale(
        customerName: '',
        itemDescription: 'Case',
        price: 1000,
        amountPaid: 1000,
      );
      expect(receipt.customerName, 'Walk-in Customer');
      expect(sales.recentSales.first.customerName, 'Walk-in Customer');
    });

    test('bumps todaysSalesTotal by the net price, not the raw price', () {
      final totalBefore = sales.todaysSalesTotal.value;
      sales.addSale(
        customerName: 'X',
        itemDescription: 'Y',
        price: 10000,
        discount: 1000,
        amountPaid: 9000,
      );
      expect(sales.todaysSalesTotal.value, totalBefore + 9000);
    });

    test('a partial payment adds the remaining balance to udharOutstanding', () {
      final udharBefore = sales.udharOutstanding.value;
      final countBefore = sales.transactionsToday.value;
      sales.addSale(
        customerName: 'X',
        itemDescription: 'Y',
        price: 20000,
        amountPaid: 12000,
      );

      expect(sales.udharOutstanding.value, udharBefore + 8000);
      expect(sales.transactionsToday.value, countBefore + 1);
    });

    test('selling a real iPhone unit marks it Sold in Inventory', () {
      final unit = inventory.sellableIphoneUnits.first;
      sales.addSale(
        customerName: 'X',
        itemDescription: unit.model,
        price: unit.salePrice,
        amountPaid: unit.salePrice,
        soldIphoneUnitId: unit.id,
      );

      final updated = inventory.iphoneUnits.firstWhere((u) => u.id == unit.id);
      expect(updated.status, UnitStockStatus.sold);
      expect(inventory.sellableIphoneUnits.any((u) => u.id == unit.id), isFalse);
    });

    test('selling a real Android product decrements its quantity by one', () {
      final product = inventory.sellableAndroidProducts.first;
      final qtyBefore = product.quantity;
      sales.addSale(
        customerName: 'X',
        itemDescription: product.model,
        price: product.salePrice,
        amountPaid: product.salePrice,
        soldAndroidProductId: product.id,
      );

      final updated = inventory.androidProducts.firstWhere((p) => p.id == product.id);
      expect(updated.quantity, qtyBefore - 1);
    });

    test('a custom item (no inventory id) never touches Inventory', () {
      final iphoneCountBefore = inventory.iphoneUnits.length;
      final androidCountBefore = inventory.androidProducts.length;

      sales.addSale(customerName: 'X', itemDescription: 'Screen protector', price: 500, amountPaid: 500);

      expect(inventory.iphoneUnits.length, iphoneCountBefore);
      expect(inventory.androidProducts.length, androidCountBefore);
    });
  });
}