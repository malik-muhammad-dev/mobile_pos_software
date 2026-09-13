import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/widgets/receipt_view.dart';
import '../../../inventory/presentations/controllers/inventory_controller.dart';
import '../widgets/new_sale_dialog.dart';

/// One line in the "Today's Activity" list. Placeholder shape only — once
/// the real Sales data layer exists this becomes a proper Sale model read
/// from SQLite, but the UI below doesn't need to change when that happens.
/// `price` is the full listed price; `discount` is knocked off at the
/// counter (e.g. haggling), and `netPrice` (price − discount) is what the
/// customer actually owes. `amountPaid` may be less than `netPrice` — the
/// difference is what's owed (Udhar), not the whole sale amount.
class SampleSaleEntry {
  const SampleSaleEntry({
    required this.time,
    required this.customerName,
    required this.itemDescription,
    required this.price,
    this.discount = 0,
    required this.amountPaid,
  });

  final String time;
  final String customerName;
  final String itemDescription;
  final int price;
  final int discount;
  final int amountPaid;

  int get netPrice => (price - discount).clamp(0, price);
  int get balanceDue => (netPrice - amountPaid).clamp(0, netPrice);
  bool get isUdhar => balanceDue > 0;
  bool get hasDiscount => discount > 0;
}

/// Sales screen state. This is intentionally placeholder-only for now — per
/// the UI-first build order, every number here is sample data so the screen
/// can be reviewed before any real database wiring happens. Nothing here
/// should be mistaken for the real Sales/Udhar logic yet.
class SalesController extends GetxController {
  final RxInt todaysSalesTotal = 0.obs;
  final RxInt udharOutstanding = 0.obs;
  final RxInt transactionsToday = 0.obs;
  final RxList<SampleSaleEntry> recentSales = <SampleSaleEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    final sample = <SampleSaleEntry>[
      const SampleSaleEntry(time: '11:42 AM', customerName: 'Walk-in Customer', itemDescription: 'iPhone 13 Pro 128GB', price: 45000, amountPaid: 45000),
      const SampleSaleEntry(time: '11:10 AM', customerName: 'Bilal Rasheed', itemDescription: 'iPhone 12 64GB', price: 128000, amountPaid: 80000),
      const SampleSaleEntry(time: '10:35 AM', customerName: 'Walk-in Customer', itemDescription: 'Screen protector', price: 8500, amountPaid: 8500),
      // Demonstrates a discount: listed at 62,000, haggled down by 2,000,
      // customer paid the full discounted (net) price — fully paid, no Udhar.
      const SampleSaleEntry(time: '10:02 AM', customerName: 'Zainab Traders', itemDescription: 'Galaxy S23 256GB', price: 62000, discount: 2000, amountPaid: 60000),
      const SampleSaleEntry(time: '09:47 AM', customerName: 'Fahad Iqbal', itemDescription: 'Redmi Note 12', price: 35000, amountPaid: 20000),
    ];
    recentSales.assignAll(sample);
    todaysSalesTotal.value = sample.fold<int>(0, (sum, s) => sum + s.netPrice);
    udharOutstanding.value = sample.fold<int>(0, (sum, s) => sum + s.balanceDue);
    transactionsToday.value = sample.length;
  }

  void onNewSaleTapped() {
    Get.dialog(const NewSaleDialog());
  }

  /// Demo-only: appends a sale to the sample list, bumps the stat cards to
  /// match, and — if the item being sold is a real Inventory unit rather
  /// than a custom/manual item — tells Inventory it was sold so stock stays
  /// consistent between the two screens. There's no real invoice or
  /// database write behind this yet; it exists so the whole flow (pick a
  /// device → take payment → get a receipt) can be shown to a client.
  ///
  /// `price` is the device's listed sale price; `discount` (optional) is
  /// knocked off at the counter — everything downstream (stats, the
  /// receipt, Udhar) is based on the resulting net price, not the raw price.
  ReceiptData addSale({
    required String customerName,
    required String itemDescription,
    required int price,
    int discount = 0,
    required int amountPaid,
    String? soldIphoneUnitId,
    String? soldAndroidProductId,
  }) {
    final resolvedCustomer = customerName.isEmpty ? 'Walk-in Customer' : customerName;
    final entry = SampleSaleEntry(
      time: DateFormat('h:mm a').format(DateTime.now()),
      customerName: resolvedCustomer,
      itemDescription: itemDescription,
      price: price,
      discount: discount,
      amountPaid: amountPaid,
    );

    recentSales.insert(0, entry);
    todaysSalesTotal.value += entry.netPrice;
    transactionsToday.value += 1;
    udharOutstanding.value += entry.balanceDue;

    if (soldIphoneUnitId != null) {
      Get.find<InventoryController>().markIphoneUnitSold(soldIphoneUnitId);
    } else if (soldAndroidProductId != null) {
      Get.find<InventoryController>().decrementAndroidStock(soldAndroidProductId);
    }

    final cashierName = Get.find<SessionService>().currentStaff.value?.name ?? 'Staff';
    // Returned rather than shown here — the New Sale dialog needs to close
    // itself (Get.back()) *before* the receipt opens, otherwise the two
    // dialogs stack and the very next Get.back() closes the receipt instead.
    return ReceiptData(
      customerName: resolvedCustomer,
      itemDescription: itemDescription,
      price: price,
      discount: discount,
      amountPaid: amountPaid,
      cashierName: cashierName,
      dateTime: DateTime.now(),
    );
  }
}