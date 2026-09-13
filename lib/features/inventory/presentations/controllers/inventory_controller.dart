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

/// Standard iPhone model names for the Add Stock / sell-a-device pickers —
/// lets a shop pick a model instead of typing it every time, while still
/// allowing a custom entry for anything not on this list (a very old model,
/// a regional variant, etc.).
const List<String> standardIphoneModels = [
  'iPhone 6', 'iPhone 6 Plus', 'iPhone 6S', 'iPhone 6S Plus',
  'iPhone 7', 'iPhone 7 Plus', 'iPhone 8', 'iPhone 8 Plus',
  'iPhone X', 'iPhone XR', 'iPhone XS', 'iPhone XS Max',
  'iPhone 11', 'iPhone 11 Pro', 'iPhone 11 Pro Max',
  'iPhone 12', 'iPhone 12 Mini', 'iPhone 12 Pro', 'iPhone 12 Pro Max',
  'iPhone 13', 'iPhone 13 Mini', 'iPhone 13 Pro', 'iPhone 13 Pro Max',
  'iPhone 14', 'iPhone 14 Plus', 'iPhone 14 Pro', 'iPhone 14 Pro Max',
  'iPhone 15', 'iPhone 15 Plus', 'iPhone 15 Pro', 'iPhone 15 Pro Max',
  'iPhone 16', 'iPhone 16 Plus', 'iPhone 16 Pro', 'iPhone 16 Pro Max',
];

/// A single physical iPhone in stock — one row per unit, not per model,
/// because compliance status and IMEI only make sense per-unit. `id` exists
/// purely so Sales can find-and-update the exact unit it just sold (mark it
/// Sold) without relying on fragile field-by-field matching.
///
/// Two prices, on purpose: `costPrice` is what the shop paid for it,
/// `salePrice` is the listed price a customer is charged — a phone shop's
/// margin lives in the gap between the two, and New Sale may discount off
/// `salePrice` further at the counter.
class SampleIphoneUnit {
  const SampleIphoneUnit({
    required this.id,
    required this.model,
    required this.storage,
    required this.color,
    required this.condition,
    required this.imei,
    required this.compliance,
    required this.batteryHealth,
    required this.status,
    required this.costPrice,
    required this.salePrice,
  });

  final String id;
  final String model;
  final String storage;
  final String color;
  final String condition;
  final String imei;
  final ComplianceStatus compliance;
  final int batteryHealth;
  final UnitStockStatus status;
  final int costPrice;
  final int salePrice;

  SampleIphoneUnit copyWith({UnitStockStatus? status}) {
    return SampleIphoneUnit(
      id: id,
      model: model,
      storage: storage,
      color: color,
      condition: condition,
      imei: imei,
      compliance: compliance,
      batteryHealth: batteryHealth,
      status: status ?? this.status,
      costPrice: costPrice,
      salePrice: salePrice,
    );
  }
}

/// One Android model line — quantity-based, no per-unit IMEI tracking.
/// Same cost-vs-sale split as SampleIphoneUnit, per unit of quantity.
class SampleAndroidProduct {
  const SampleAndroidProduct({
    required this.id,
    required this.brand,
    required this.model,
    required this.storage,
    required this.ram,
    required this.color,
    required this.condition,
    required this.quantity,
    required this.costPrice,
    required this.salePrice,
  });

  final String id;
  final String brand;
  final String model;
  final String storage;
  final String ram;
  final String color;
  final String condition;
  final int quantity;
  final int costPrice;
  final int salePrice;

  SampleAndroidProduct copyWith({int? quantity}) {
    return SampleAndroidProduct(
      id: id,
      brand: brand,
      model: model,
      storage: storage,
      ram: ram,
      color: color,
      condition: condition,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice,
      salePrice: salePrice,
    );
  }
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
  int _nextIphoneId = 1;
  int _nextAndroidId = 1;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    iphoneUnits.assignAll([
      SampleIphoneUnit(
        id: 'ip-${_nextIphoneId++}',
        model: 'iPhone 13 Pro',
        storage: '128GB',
        color: 'Graphite',
        condition: 'Used — Excellent',
        imei: '356938035643809',
        compliance: ComplianceStatus.ptaApproved,
        batteryHealth: 91,
        status: UnitStockStatus.inStock,
        costPrice: 162000,
        salePrice: 185000,
      ),
      SampleIphoneUnit(
        id: 'ip-${_nextIphoneId++}',
        model: 'iPhone 13 Pro',
        storage: '256GB',
        color: 'Sierra Blue',
        condition: 'Used — Good',
        imei: '356938035698214',
        compliance: ComplianceStatus.nonPta,
        batteryHealth: 84,
        status: UnitStockStatus.inStock,
        costPrice: 150000,
        salePrice: 172000,
      ),
      SampleIphoneUnit(
        id: 'ip-${_nextIphoneId++}',
        model: 'iPhone 12',
        storage: '64GB',
        color: 'Black',
        condition: 'Used — Good',
        imei: '356938035611023',
        compliance: ComplianceStatus.jv,
        batteryHealth: 88,
        status: UnitStockStatus.reserved,
        costPrice: 85000,
        salePrice: 98000,
      ),
      SampleIphoneUnit(
        id: 'ip-${_nextIphoneId++}',
        model: 'iPhone 15',
        storage: '128GB',
        color: 'Blue',
        condition: 'New',
        imei: '356938035677431',
        compliance: ComplianceStatus.ptaApproved,
        batteryHealth: 100,
        status: UnitStockStatus.inStock,
        costPrice: 238000,
        salePrice: 265000,
      ),
      SampleIphoneUnit(
        id: 'ip-${_nextIphoneId++}',
        model: 'iPhone 11',
        storage: '128GB',
        color: 'White',
        condition: 'Used — Fair',
        imei: '356938035622987',
        compliance: ComplianceStatus.factoryUnlocked,
        batteryHealth: 79,
        status: UnitStockStatus.sold,
        costPrice: 52000,
        salePrice: 62000,
      ),
    ]);

    androidProducts.assignAll([
      SampleAndroidProduct(
        id: 'an-${_nextAndroidId++}',
        brand: 'Samsung',
        model: 'Galaxy S23',
        storage: '256GB',
        ram: '8GB',
        color: 'Phantom Black',
        condition: 'New',
        quantity: 6,
        costPrice: 185000,
        salePrice: 210000,
      ),
      SampleAndroidProduct(
        id: 'an-${_nextAndroidId++}',
        brand: 'Xiaomi',
        model: 'Redmi Note 12',
        storage: '128GB',
        ram: '6GB',
        color: 'Blue',
        condition: 'New',
        quantity: 2,
        costPrice: 35000,
        salePrice: 40000,
      ),
      SampleAndroidProduct(
        id: 'an-${_nextAndroidId++}',
        brand: 'Infinix',
        model: 'Hot 30',
        storage: '128GB',
        ram: '8GB',
        color: 'Green',
        condition: 'New',
        quantity: 1,
        costPrice: 24500,
        salePrice: 29000,
      ),
      SampleAndroidProduct(
        id: 'an-${_nextAndroidId++}',
        brand: 'Samsung',
        model: 'Galaxy A14',
        storage: '64GB',
        ram: '4GB',
        color: 'Silver',
        condition: 'Used',
        quantity: 4,
        costPrice: 30000,
        salePrice: 35000,
      ),
    ]);
  }

  void selectTab(InventoryTab tab) => selectedTab.value = tab;

  int get iphoneUnitsInStockCount => iphoneUnits.where((u) => u.status == UnitStockStatus.inStock).length;

  /// Retail value of in-stock units (sum of sale prices) — what the shop
  /// could earn if everything currently in stock sold at full price.
  int get iphoneStockValue =>
      iphoneUnits.where((u) => u.status == UnitStockStatus.inStock).fold<int>(0, (sum, u) => sum + u.salePrice);

  int get iphoneLowStockModelCount {
    final byModel = <String, int>{};
    for (final unit in iphoneUnits.where((u) => u.status == UnitStockStatus.inStock)) {
      byModel[unit.model] = (byModel[unit.model] ?? 0) + 1;
    }
    return byModel.values.where((count) => count < _lowStockThreshold).length;
  }

  int get androidUnitsInStockCount => androidProducts.fold<int>(0, (sum, p) => sum + p.quantity);

  /// Retail value of Android stock — same idea as iphoneStockValue.
  int get androidStockValue => androidProducts.fold<int>(0, (sum, p) => sum + (p.salePrice * p.quantity));

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
    required int costPrice,
    required int salePrice,
  }) {
    iphoneUnits.insert(
      0,
      SampleIphoneUnit(
        id: 'ip-${_nextIphoneId++}',
        model: model,
        storage: storage,
        color: color,
        condition: condition,
        imei: imei,
        compliance: compliance,
        batteryHealth: batteryHealth,
        status: UnitStockStatus.inStock,
        costPrice: costPrice,
        salePrice: salePrice,
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
    required int costPrice,
    required int salePrice,
  }) {
    androidProducts.insert(
      0,
      SampleAndroidProduct(
        id: 'an-${_nextAndroidId++}',
        brand: brand,
        model: model,
        storage: storage,
        ram: ram,
        color: color,
        condition: condition,
        quantity: quantity,
        costPrice: costPrice,
        salePrice: salePrice,
      ),
    );
  }

  /// Called by Sales once a specific iPhone unit is actually sold — this is
  /// what makes "New Sale" a real sale instead of a number on a screen: the
  /// unit disappears from "in stock" counts and shows as Sold here too.
  void markIphoneUnitSold(String id) {
    final index = iphoneUnits.indexWhere((u) => u.id == id);
    if (index == -1) return;
    iphoneUnits[index] = iphoneUnits[index].copyWith(status: UnitStockStatus.sold);
  }

  /// Called by Sales once an Android unit is sold — decrements that
  /// product's quantity by one, same idea as markIphoneUnitSold.
  void decrementAndroidStock(String id) {
    final index = androidProducts.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final product = androidProducts[index];
    if (product.quantity <= 0) return;
    androidProducts[index] = product.copyWith(quantity: product.quantity - 1);
  }

  /// All iPhone units still available to sell — feeds Sales' device picker.
  List<SampleIphoneUnit> get sellableIphoneUnits =>
      iphoneUnits.where((u) => u.status == UnitStockStatus.inStock).toList();

  /// All Android products with stock left — feeds Sales' device picker.
  List<SampleAndroidProduct> get sellableAndroidProducts =>
      androidProducts.where((p) => p.quantity > 0).toList();
}