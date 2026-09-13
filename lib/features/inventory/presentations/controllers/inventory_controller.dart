import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../widgets/add_stock_dialog.dart';

/// Which tab of Inventory is showing. iPhone and Android are modeled very
/// differently on purpose — iPhones are tracked per physical unit (each has
/// its own IMEI, PTA/compliance status, battery health), while Androids are
/// tracked per product with a plain quantity, matching the real schema
/// (iphone_units vs android_products).
enum InventoryTab { iphone, android }

/// A single physical iPhone in stock — one row per unit, not per model,
/// because compliance status and IMEI only make sense per-unit.
class SampleIphoneUnit {
  const SampleIphoneUnit({
    required this.model,
    required this.storage,
    required this.color,
    required this.condition,
    required this.imei,
    required this.compliance,
    required this.batteryHealth,
    required this.status,
    required this.price,
  });

  final String model;
  final String storage;
  final String color;
  final String condition;
  final String imei;
  final ComplianceStatus compliance;
  final int batteryHealth;
  final UnitStockStatus status;
  final int price;
}

/// One Android model line — quantity-based, no per-unit IMEI tracking.
class SampleAndroidProduct {
  const SampleAndroidProduct({
    required this.brand,
    required this.model,
    required this.storage,
    required this.ram,
    required this.color,
    required this.condition,
    required this.quantity,
    required this.price,
  });

  final String brand;
  final String model;
  final String storage;
  final String ram;
  final String color;
  final String condition;
  final int quantity;
  final int price;
}

/// Mirrors the DB's iphone_units.status check constraint.
enum UnitStockStatus { inStock, reserved, sold }

extension UnitStockStatusX on UnitStockStatus {
  String get label {
    switch (this) {
      case UnitStockStatus.inStock:
        return 'In Stock';
      case UnitStockStatus.reserved:
        return 'Reserved';
      case UnitStockStatus.sold:
        return 'Sold';
    }
  }

  Color get ink {
    switch (this) {
      case UnitStockStatus.inStock:
        return AppColors.inStock;
      case UnitStockStatus.reserved:
        return AppColors.reserved;
      case UnitStockStatus.sold:
        return AppColors.sold;
    }
  }

  Color get bg => ink.withValues(alpha: 0.12);

  IconData get icon {
    switch (this) {
      case UnitStockStatus.inStock:
        return Icons.check_circle_outline;
      case UnitStockStatus.reserved:
        return Icons.schedule_outlined;
      case UnitStockStatus.sold:
        return Icons.local_shipping_outlined;
    }
  }
}

/// Inventory screen state. Placeholder-only, per the UI-first build order —
/// every unit/product below is sample data so the screen can be reviewed
/// before the real iphone_units / android_products tables are wired in.
/// The 3 (`_lowStockThreshold`) mirrors shop_config's default so the sample
/// "low stock" flags look realistic; once wired, this reads the real value.
class InventoryController extends GetxController {
  final Rx<InventoryTab> selectedTab = InventoryTab.iphone.obs;

  final RxList<SampleIphoneUnit> iphoneUnits = <SampleIphoneUnit>[].obs;
  final RxList<SampleAndroidProduct> androidProducts = <SampleAndroidProduct>[].obs;

  static const int _lowStockThreshold = 3;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    iphoneUnits.assignAll(const [
      SampleIphoneUnit(
        model: 'iPhone 13 Pro',
        storage: '128GB',
        color: 'Graphite',
        condition: 'Used — Excellent',
        imei: '356938035643809',
        compliance: ComplianceStatus.ptaApproved,
        batteryHealth: 91,
        status: UnitStockStatus.inStock,
        price: 185000,
      ),
      SampleIphoneUnit(
        model: 'iPhone 13 Pro',
        storage: '256GB',
        color: 'Sierra Blue',
        condition: 'Used — Good',
        imei: '356938035698214',
        compliance: ComplianceStatus.nonPta,
        batteryHealth: 84,
        status: UnitStockStatus.inStock,
        price: 172000,
      ),
      SampleIphoneUnit(
        model: 'iPhone 12',
        storage: '64GB',
        color: 'Black',
        condition: 'Used — Good',
        imei: '356938035611023',
        compliance: ComplianceStatus.jv,
        batteryHealth: 88,
        status: UnitStockStatus.reserved,
        price: 98000,
      ),
      SampleIphoneUnit(
        model: 'iPhone 15',
        storage: '128GB',
        color: 'Blue',
        condition: 'New',
        imei: '356938035677431',
        compliance: ComplianceStatus.ptaApproved,
        batteryHealth: 100,
        status: UnitStockStatus.inStock,
        price: 265000,
      ),
      SampleIphoneUnit(
        model: 'iPhone 11',
        storage: '128GB',
        color: 'White',
        condition: 'Used — Fair',
        imei: '356938035622987',
        compliance: ComplianceStatus.factoryUnlocked,
        batteryHealth: 79,
        status: UnitStockStatus.sold,
        price: 62000,
      ),
    ]);

    androidProducts.assignAll(const [
      SampleAndroidProduct(
        brand: 'Samsung',
        model: 'Galaxy S23',
        storage: '256GB',
        ram: '8GB',
        color: 'Phantom Black',
        condition: 'New',
        quantity: 6,
        price: 210000,
      ),
      SampleAndroidProduct(
        brand: 'Xiaomi',
        model: 'Redmi Note 12',
        storage: '128GB',
        ram: '6GB',
        color: 'Blue',
        condition: 'New',
        quantity: 2,
        price: 42000,
      ),
      SampleAndroidProduct(
        brand: 'Infinix',
        model: 'Hot 30',
        storage: '128GB',
        ram: '8GB',
        color: 'Green',
        condition: 'New',
        quantity: 1,
        price: 29000,
      ),
      SampleAndroidProduct(
        brand: 'Samsung',
        model: 'Galaxy A14',
        storage: '64GB',
        ram: '4GB',
        color: 'Silver',
        condition: 'Used',
        quantity: 4,
        price: 35000,
      ),
    ]);
  }

  void selectTab(InventoryTab tab) => selectedTab.value = tab;

  int get iphoneUnitsInStockCount => iphoneUnits.where((u) => u.status == UnitStockStatus.inStock).length;

  int get iphoneStockValue =>
      iphoneUnits.where((u) => u.status == UnitStockStatus.inStock).fold<int>(0, (sum, u) => sum + u.price);

  int get iphoneLowStockModelCount {
    final byModel = <String, int>{};
    for (final unit in iphoneUnits.where((u) => u.status == UnitStockStatus.inStock)) {
      byModel[unit.model] = (byModel[unit.model] ?? 0) + 1;
    }
    return byModel.values.where((count) => count < _lowStockThreshold).length;
  }

  int get androidUnitsInStockCount => androidProducts.fold<int>(0, (sum, p) => sum + p.quantity);

  int get androidStockValue => androidProducts.fold<int>(0, (sum, p) => sum + (p.price * p.quantity));

  int get androidLowStockModelCount => androidProducts.where((p) => p.quantity < _lowStockThreshold).length;

  bool isAndroidLowStock(SampleAndroidProduct product) => product.quantity < _lowStockThreshold;

  void onAddStockTapped() {
    Get.dialog(AddStockDialog(initialTab: selectedTab.value));
  }

  /// Demo-only: appends straight to the sample list. No real iphone_units
  /// row is written yet — this exists so the flow can be shown to a client
  /// before the real database wiring happens.
  void addIphoneUnit({
    required String model,
    required String storage,
    required String color,
    required String condition,
    required String imei,
    required ComplianceStatus compliance,
    required int batteryHealth,
    required int price,
  }) {
    iphoneUnits.insert(
      0,
      SampleIphoneUnit(
        model: model,
        storage: storage,
        color: color,
        condition: condition,
        imei: imei,
        compliance: compliance,
        batteryHealth: batteryHealth,
        status: UnitStockStatus.inStock,
        price: price,
      ),
    );
  }

  /// Demo-only: appends straight to the sample list — see addIphoneUnit.
  void addAndroidProduct({
    required String brand,
    required String model,
    required String storage,
    required String ram,
    required String color,
    required String condition,
    required int quantity,
    required int price,
  }) {
    androidProducts.insert(
      0,
      SampleAndroidProduct(
        brand: brand,
        model: model,
        storage: storage,
        ram: ram,
        color: color,
        condition: condition,
        quantity: quantity,
        price: price,
      ),
    );
  }
}