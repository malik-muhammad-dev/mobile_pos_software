import 'package:get/get.dart';
import '../../../customers_ledger/presentation/controllers/customers_controller.dart';
import '../../../inventory/presentations/controllers/inventory_controller.dart';

/// Which window of history the dashboard is summarizing. No custom date
/// picker yet on purpose — these four presets cover what an owner actually
/// checks day to day; a real range picker can be added once this is wired
/// to a real query instead of filtering a sample list.
enum ReportRange { today, last7Days, last30Days, thisMonth }

extension ReportRangeX on ReportRange {
  String get label {
    switch (this) {
      case ReportRange.today:
        return 'Today';
      case ReportRange.last7Days:
        return 'Last 7 Days';
      case ReportRange.last30Days:
        return 'Last 30 Days';
      case ReportRange.thisMonth:
        return 'This Month';
    }
  }
}

/// One historical sale, shaped like what a real report query would return
/// by joining sales + sale_items + the product tables (for cost_price, to
/// get profit). This is its own sample dataset — separate from Sales'
/// "Today's Activity" list — because Reports needs multi-day history with
/// cost attached, which the Sales sample list doesn't carry.
class _SampleReportSale {
  const _SampleReportSale({
    required this.date,
    required this.item,
    required this.paymentMethod,
    required this.revenue,
    required this.cost,
  });

  final DateTime date;
  final String item;
  final String paymentMethod; // 'Cash' | 'Card' | 'Bank' | 'Udhar'
  final int revenue; // net amount charged (after any discount)
  final int cost; // cost price — the gap to revenue is profit
}

/// One row in the Top Selling Models list.
class TopModelStat {
  const TopModelStat({required this.name, required this.unitsSold, required this.revenue});

  final String name;
  final int unitsSold;
  final int revenue;
}

/// Reports screen state (Owner-only). Placeholder-only, per the UI-first
/// build order — the sales history below is sample data so the dashboard
/// can be reviewed before it's wired to real sales/sale_items queries.
/// Stock alerts and the Udhar total, though, read live from
/// InventoryController/CustomersController — those are current-state facts
/// the rest of the app already tracks, not history Reports owns itself.
class ReportsController extends GetxController {
  final Rx<ReportRange> selectedRange = ReportRange.last7Days.obs;

  final List<_SampleReportSale> _sales = [];

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    DateTime d(int daysAgo, int hour) =>
        DateTime(now.year, now.month, now.day, hour).subtract(Duration(days: daysAgo));

    _sales.addAll([
      // Today — busier morning, one Udhar sale.
      _SampleReportSale(date: d(0, 11), item: 'iPhone 13 Pro 128GB', paymentMethod: 'Cash', revenue: 45000, cost: 38000),
      _SampleReportSale(date: d(0, 11), item: 'iPhone 12 64GB', paymentMethod: 'Udhar', revenue: 128000, cost: 108000),
      _SampleReportSale(date: d(0, 10), item: 'Screen Protector', paymentMethod: 'Cash', revenue: 8500, cost: 2200),
      _SampleReportSale(date: d(0, 10), item: 'Galaxy S23 256GB', paymentMethod: 'Bank', revenue: 60000, cost: 51000),
      _SampleReportSale(date: d(0, 9), item: 'Redmi Note 12', paymentMethod: 'Udhar', revenue: 35000, cost: 29500),

      // Yesterday — a slower day.
      _SampleReportSale(date: d(1, 15), item: 'iPhone 15 128GB', paymentMethod: 'Card', revenue: 265000, cost: 238000),
      _SampleReportSale(date: d(1, 12), item: 'Charger Cable', paymentMethod: 'Cash', revenue: 1500, cost: 400),

      // 2 days ago
      _SampleReportSale(date: d(2, 17), item: 'Galaxy A14 64GB', paymentMethod: 'Cash', revenue: 35000, cost: 30000),
      _SampleReportSale(date: d(2, 14), item: 'iPhone 11 128GB', paymentMethod: 'Udhar', revenue: 62000, cost: 52000),
      _SampleReportSale(date: d(2, 11), item: 'Tempered Glass', paymentMethod: 'Cash', revenue: 1200, cost: 300),

      // 3 days ago — weekend-style spike.
      _SampleReportSale(date: d(3, 18), item: 'iPhone 13 Pro 256GB', paymentMethod: 'Card', revenue: 172000, cost: 150000),
      _SampleReportSale(date: d(3, 16), item: 'iPhone 14 Pro 128GB', paymentMethod: 'Bank', revenue: 238000, cost: 210000),
      _SampleReportSale(date: d(3, 13), item: 'Hot 30 128GB', paymentMethod: 'Cash', revenue: 29000, cost: 24500),
      _SampleReportSale(date: d(3, 11), item: 'Redmi Note 12', paymentMethod: 'Cash', revenue: 40000, cost: 35000),

      // 4-6 days ago
      _SampleReportSale(date: d(4, 12), item: 'Galaxy S23 256GB', paymentMethod: 'Udhar', revenue: 210000, cost: 185000),
      _SampleReportSale(date: d(5, 10), item: 'Earphones', paymentMethod: 'Cash', revenue: 2000, cost: 600),
      _SampleReportSale(date: d(5, 15), item: 'iPhone 12 64GB', paymentMethod: 'Card', revenue: 98000, cost: 85000),
      _SampleReportSale(date: d(6, 14), item: 'Redmi Note 12', paymentMethod: 'Cash', revenue: 40000, cost: 35000),
      _SampleReportSale(date: d(6, 11), item: 'Back Cover', paymentMethod: 'Cash', revenue: 800, cost: 200),

      // Older, within the last 30 days / this month — keeps the wider
      // ranges meaningfully bigger than "Last 7 Days" instead of flat.
      _SampleReportSale(date: d(9, 12), item: 'iPhone 13 Pro 128GB', paymentMethod: 'Bank', revenue: 185000, cost: 162000),
      _SampleReportSale(date: d(11, 16), item: 'Galaxy A14 64GB', paymentMethod: 'Cash', revenue: 35000, cost: 30000),
      _SampleReportSale(date: d(14, 13), item: 'iPhone 11 128GB', paymentMethod: 'Udhar', revenue: 62000, cost: 52000),
      _SampleReportSale(date: d(16, 10), item: 'Screen Protector', paymentMethod: 'Cash', revenue: 8500, cost: 2200),
      _SampleReportSale(date: d(18, 14), item: 'Redmi Note 12', paymentMethod: 'Card', revenue: 40000, cost: 35000),
      _SampleReportSale(date: d(21, 11), item: 'iPhone 14 Pro 128GB', paymentMethod: 'Bank', revenue: 238000, cost: 210000),
      _SampleReportSale(date: d(24, 15), item: 'Galaxy S23 256GB', paymentMethod: 'Cash', revenue: 210000, cost: 185000),
      _SampleReportSale(date: d(27, 12), item: 'Hot 30 128GB', paymentMethod: 'Udhar', revenue: 29000, cost: 24500),
    ]);
  }

  void setRange(ReportRange range) => selectedRange.value = range;

  List<_SampleReportSale> get _filtered {
    final now = DateTime.now();
    bool inRange(DateTime date) {
      switch (selectedRange.value) {
        case ReportRange.today:
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case ReportRange.last7Days:
          return date.isAfter(now.subtract(const Duration(days: 7)));
        case ReportRange.last30Days:
          return date.isAfter(now.subtract(const Duration(days: 30)));
        case ReportRange.thisMonth:
          return date.year == now.year && date.month == now.month;
      }
    }

    return _sales.where((s) => inRange(s.date)).toList();
  }

  int get totalRevenue => _filtered.fold<int>(0, (sum, s) => sum + s.revenue);

  int get totalProfit => _filtered.fold<int>(0, (sum, s) => sum + (s.revenue - s.cost));

  int get transactionCount => _filtered.length;

  int get averageSale => transactionCount == 0 ? 0 : (totalRevenue / transactionCount).round();

  /// Fixed display order regardless of what the sample data contains, so
  /// the breakdown always shows all four methods (even at Rs. 0) rather
  /// than reshuffling as the range changes.
  static const List<String> paymentMethods = ['Cash', 'Card', 'Bank', 'Udhar'];

  Map<String, int> get paymentMethodBreakdown {
    final totals = {for (final m in paymentMethods) m: 0};
    for (final sale in _filtered) {
      totals[sale.paymentMethod] = (totals[sale.paymentMethod] ?? 0) + sale.revenue;
    }
    return totals;
  }

  /// Top 5 models by revenue in the selected range, most-earned first.
  List<TopModelStat> get topModels {
    final byItem = <String, List<int>>{}; // item -> [unitsSold, revenue]
    for (final sale in _filtered) {
      final entry = byItem.putIfAbsent(sale.item, () => [0, 0]);
      entry[0] += 1;
      entry[1] += sale.revenue;
    }
    final stats = [
      for (final e in byItem.entries) TopModelStat(name: e.key, unitsSold: e.value[0], revenue: e.value[1]),
    ];
    stats.sort((a, b) => b.revenue.compareTo(a.revenue));
    return stats.take(5).toList();
  }

  // --- Live current-state facts, not history — read from the controllers
  // that already own them, same as Sales reads Inventory when a device is
  // sold. Not affected by selectedRange; these are "right now" numbers.

  InventoryController get _inventory => Get.find<InventoryController>();

  CustomersController get _customers => Get.find<CustomersController>();

  int get lowStockIphoneModelCount => _inventory.iphoneLowStockModelCount;

  int get lowStockAndroidModelCount => _inventory.androidLowStockModelCount;

  List<SampleAndroidProduct> get lowStockAndroidProducts =>
      _inventory.androidProducts.where(_inventory.isAndroidLowStock).toList();

  int get outstandingUdhar => _customers.totalOutstanding;

  int get customersWithBalanceCount => _customers.customersWithBalanceCount;
}