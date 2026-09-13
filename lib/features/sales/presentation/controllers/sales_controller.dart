import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/new_sale_dialog.dart';

/// One line in the "Today's Activity" list. Placeholder shape only — once
/// the real Sales data layer exists this becomes a proper Sale model read
/// from SQLite, but the UI below doesn't need to change when that happens.
class SampleSaleEntry {
  const SampleSaleEntry({
    required this.time,
    required this.customerName,
    required this.amount,
    required this.isUdhar,
  });

  final String time;
  final String customerName;
  final int amount;
  final bool isUdhar;
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
      const SampleSaleEntry(time: '11:42 AM', customerName: 'Walk-in Customer', amount: 45000, isUdhar: false),
      const SampleSaleEntry(time: '11:10 AM', customerName: 'Bilal Rasheed', amount: 128000, isUdhar: true),
      const SampleSaleEntry(time: '10:35 AM', customerName: 'Walk-in Customer', amount: 8500, isUdhar: false),
      const SampleSaleEntry(time: '10:02 AM', customerName: 'Zainab Traders', amount: 62000, isUdhar: false),
      const SampleSaleEntry(time: '09:47 AM', customerName: 'Fahad Iqbal', amount: 35000, isUdhar: true),
    ];
    recentSales.assignAll(sample);
    todaysSalesTotal.value = sample.fold<int>(0, (sum, s) => sum + s.amount);
    udharOutstanding.value = sample.where((s) => s.isUdhar).fold<int>(0, (sum, s) => sum + s.amount);
    transactionsToday.value = sample.length;
  }

  void onNewSaleTapped() {
    Get.dialog(NewSaleDialog());
  }

  /// Demo-only: appends a sale straight to the sample list and bumps the
  /// stat cards to match. There's no real product picker or invoice behind
  /// this yet — it exists so the flow can be shown to a client before the
  /// real Sales data layer is wired in.
  void addSale({required String customerName, required int amount, required bool isUdhar}) {
    final entry = SampleSaleEntry(
      time: DateFormat('h:mm a').format(DateTime.now()),
      customerName: customerName.isEmpty ? 'Walk-in Customer' : customerName,
      amount: amount,
      isUdhar: isUdhar,
    );
    recentSales.insert(0, entry);
    todaysSalesTotal.value += amount;
    transactionsToday.value += 1;
    if (isUdhar) udharOutstanding.value += amount;
  }
}