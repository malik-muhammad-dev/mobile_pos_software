import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_shop_pos/core/widgets/status_badge.dart';
import 'package:mobile_shop_pos/features/inventory/presentations/controllers/inventory_controller.dart';

/// Logic-only coverage for Inventory — stock counts, stock value, low-stock
/// detection, and the add/sell mutations. No widgets pumped, nothing about
/// rendering; just the numbers a shop actually relies on being right.
void main() {
  late InventoryController controller;

  setUp(() {
    controller = Get.put(InventoryController(), permanent: true);
  });

  tearDown(() => Get.reset());

  group('stock counts and value', () {
    test('iphoneUnitsInStockCount only counts units still In Stock', () {
      final expected = controller.iphoneUnits.where((u) => u.status == UnitStockStatus.inStock).length;
      expect(controller.iphoneUnitsInStockCount, expected);
    });

    test('iphoneStockValue sums salePrice (not costPrice) of in-stock units only', () {
      final inStock = controller.iphoneUnits.where((u) => u.status == UnitStockStatus.inStock);
      final expectedBySalePrice = inStock.fold<int>(0, (sum, u) => sum + u.salePrice);
      final expectedByCostPrice = inStock.fold<int>(0, (sum, u) => sum + u.costPrice);

      expect(controller.iphoneStockValue, expectedBySalePrice);
      // Guards against silently swapping in cost price by accident — the
      // two totals must differ given the sample data's margins.
      expect(controller.iphoneStockValue, isNot(expectedByCostPrice));
    });

    test('androidUnitsInStockCount sums quantity across all products', () {
      final expected = controller.androidProducts.fold<int>(0, (sum, p) => sum + p.quantity);
      expect(controller.androidUnitsInStockCount, expected);
    });

    test('androidStockValue multiplies salePrice by quantity per product', () {
      final expected = controller.androidProducts.fold<int>(0, (sum, p) => sum + (p.salePrice * p.quantity));
      expect(controller.androidStockValue, expected);
    });
  });

  group('low stock detection', () {
    test('isAndroidLowStock is true only below the low-stock threshold (3)', () {
      final low = controller.androidProducts.firstWhere((p) => p.quantity < 3);
      final healthy = controller.androidProducts.firstWhere((p) => p.quantity >= 3);
      expect(controller.isAndroidLowStock(low), isTrue);
      expect(controller.isAndroidLowStock(healthy), isFalse);
    });

    test('androidLowStockModelCount counts exactly the products under threshold', () {
      final expected = controller.androidProducts.where((p) => p.quantity < 3).length;
      expect(controller.androidLowStockModelCount, expected);
    });
  });

  group('addIphoneUnit / addAndroidProduct', () {
    test('addIphoneUnit inserts a new In Stock unit at the top with both prices set', () {
      final before = controller.iphoneUnits.length;
      controller.addIphoneUnit(
        model: 'iPhone 14',
        storage: '128GB',
        color: 'Midnight',
        condition: 'New',
        imei: '111111111111111',
        compliance: ComplianceStatus.ptaApproved,
        batteryHealth: 100,
        costPrice: 200000,
        salePrice: 230000,
      );

      expect(controller.iphoneUnits.length, before + 1);
      final added = controller.iphoneUnits.first;
      expect(added.model, 'iPhone 14');
      expect(added.status, UnitStockStatus.inStock);
      expect(added.costPrice, 200000);
      expect(added.salePrice, 230000);
    });

    test('addAndroidProduct inserts a new product at the top with the given quantity and prices', () {
      final before = controller.androidProducts.length;
      controller.addAndroidProduct(
        brand: 'Vivo',
        model: 'Y100',
        storage: '128GB',
        ram: '8GB',
        color: 'Black',
        condition: 'New',
        quantity: 3,
        costPrice: 45000,
        salePrice: 52000,
      );

      expect(controller.androidProducts.length, before + 1);
      final added = controller.androidProducts.first;
      expect(added.quantity, 3);
      expect(added.costPrice, 45000);
      expect(added.salePrice, 52000);
    });
  });

  group('markIphoneUnitSold / decrementAndroidStock', () {
    test('markIphoneUnitSold flips the matching unit to Sold and removes it from sellable', () {
      final target = controller.sellableIphoneUnits.first;
      controller.markIphoneUnitSold(target.id);

      final updated = controller.iphoneUnits.firstWhere((u) => u.id == target.id);
      expect(updated.status, UnitStockStatus.sold);
      expect(controller.sellableIphoneUnits.any((u) => u.id == target.id), isFalse);
    });

    test('markIphoneUnitSold on an unknown id is a no-op', () {
      final statusesBefore = controller.iphoneUnits.map((u) => u.status).toList();
      controller.markIphoneUnitSold('does-not-exist');
      expect(controller.iphoneUnits.map((u) => u.status).toList(), statusesBefore);
    });

    test('decrementAndroidStock reduces quantity by exactly one', () {
      final target = controller.sellableAndroidProducts.first;
      final before = target.quantity;
      controller.decrementAndroidStock(target.id);

      final updated = controller.androidProducts.firstWhere((p) => p.id == target.id);
      expect(updated.quantity, before - 1);
    });

    test('decrementAndroidStock never takes quantity below zero', () {
      final target = controller.sellableAndroidProducts.reduce((a, b) => a.quantity <= b.quantity ? a : b);
      for (var i = 0; i < target.quantity; i++) {
        controller.decrementAndroidStock(target.id);
      }
      // One extra call once it's already at zero should stay at zero.
      controller.decrementAndroidStock(target.id);

      final updated = controller.androidProducts.firstWhere((p) => p.id == target.id);
      expect(updated.quantity, 0);
    });
  });

  group('sellableIphoneUnits / sellableAndroidProducts', () {
    test('sellableIphoneUnits excludes sold and reserved units', () {
      expect(controller.sellableIphoneUnits.every((u) => u.status == UnitStockStatus.inStock), isTrue);
    });

    test('sellableAndroidProducts excludes products with zero quantity', () {
      expect(controller.sellableAndroidProducts.every((p) => p.quantity > 0), isTrue);
    });
  });
}