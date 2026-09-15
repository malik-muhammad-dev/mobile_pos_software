import 'package:get/get.dart';

/// How a ledger entry affects a customer's balance: a charge adds to what
/// they owe (e.g. a sale left with a balance due), a payment reduces it
/// (money they've since paid back). Mirrors ledger_transactions.type in
/// the real schema.
enum LedgerEntryType { charge, payment }

/// One customer record. Placeholder shape only — matches the real
/// `customers` table (name, phone, cnic, credit_limit) so the eventual
/// database wiring doesn't need this shape to change.
class SampleCustomer {
  const SampleCustomer({
    required this.id,
    required this.name,
    required this.phone,
    this.cnic,
  });

  final String id;
  final String name;
  final String phone;
  final String? cnic;
}

/// One line in a customer's ledger — a charge (money now owed) or a
/// payment (money paid back). A balance is always derived from these,
/// never stored directly, matching how the real schema works too.
class SampleLedgerEntry {
  const SampleLedgerEntry({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.description,
    required this.dateTime,
  });

  final String id;
  final String customerId;
  final LedgerEntryType type;
  final int amount;
  final String description;
  final DateTime dateTime;
}

/// Customers & Ledger (Udhar) screen state. Placeholder-only, per the
/// UI-first build order — sample customers and ledger entries so the
/// screen can be reviewed before the real customers / ledger_transactions
/// tables are wired in. Note this is its own self-contained sample
/// dataset, same as Inventory was before Sales connected to it — it is
/// NOT yet linked to Sales' own sample Udhar numbers.
class CustomersController extends GetxController {
  final RxList<SampleCustomer> customers = <SampleCustomer>[].obs;
  final RxList<SampleLedgerEntry> ledgerEntries = <SampleLedgerEntry>[].obs;
  final RxString searchQuery = ''.obs;

  int _nextCustomerId = 1;
  int _nextEntryId = 1;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();

    customers.assignAll([
      SampleCustomer(id: 'cu-${_nextCustomerId++}', name: 'Ahmed Khan', phone: '0300-1234567', cnic: '35202-1234567-1'),
      SampleCustomer(id: 'cu-${_nextCustomerId++}', name: 'Bilal Rasheed', phone: '0333-9876543'),
      SampleCustomer(id: 'cu-${_nextCustomerId++}', name: 'Zainab Traders', phone: '0321-4567890'),
      SampleCustomer(id: 'cu-${_nextCustomerId++}', name: 'Fahad Iqbal', phone: '0345-1122334'),
      SampleCustomer(id: 'cu-${_nextCustomerId++}', name: 'Sana Malik', phone: '0300-7654321'),
    ]);

    final ids = customers.map((c) => c.id).toList();

    ledgerEntries.assignAll([
      // Ahmed Khan — fully cleared.
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[0], type: LedgerEntryType.charge, amount: 45000, description: 'iPhone 13 Pro 128GB', dateTime: now.subtract(const Duration(days: 20))),
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[0], type: LedgerEntryType.payment, amount: 45000, description: 'Payment received', dateTime: now.subtract(const Duration(days: 18))),

      // Bilal Rasheed — partial payment, Rs. 48,000 still owed.
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[1], type: LedgerEntryType.charge, amount: 128000, description: 'iPhone 12 64GB', dateTime: now.subtract(const Duration(days: 10))),
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[1], type: LedgerEntryType.payment, amount: 80000, description: 'Partial payment', dateTime: now.subtract(const Duration(days: 8))),

      // Zainab Traders — paid in full same day.
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[2], type: LedgerEntryType.charge, amount: 60000, description: 'Galaxy S23 256GB (after discount)', dateTime: now.subtract(const Duration(days: 5))),
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[2], type: LedgerEntryType.payment, amount: 60000, description: 'Payment received', dateTime: now.subtract(const Duration(days: 5))),

      // Fahad Iqbal — partial payment, Rs. 15,000 still owed.
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[3], type: LedgerEntryType.charge, amount: 35000, description: 'Redmi Note 12', dateTime: now.subtract(const Duration(days: 3))),
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[3], type: LedgerEntryType.payment, amount: 20000, description: 'Partial payment', dateTime: now.subtract(const Duration(days: 3))),

      // Sana Malik — older balance, only partly chipped away — the kind
      // of overdue Udhar a shop owner would actually want to notice.
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[4], type: LedgerEntryType.charge, amount: 25000, description: 'Accessories bundle', dateTime: now.subtract(const Duration(days: 45))),
      SampleLedgerEntry(id: 'lg-${_nextEntryId++}', customerId: ids[4], type: LedgerEntryType.payment, amount: 5000, description: 'Partial payment', dateTime: now.subtract(const Duration(days: 40))),
    ]);
  }

  void setSearchQuery(String query) => searchQuery.value = query;

  List<SampleCustomer> get filteredCustomers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers.where((c) => c.name.toLowerCase().contains(query) || c.phone.contains(query)).toList();
  }

  List<SampleLedgerEntry> entriesFor(String customerId) {
    final entries = ledgerEntries.where((e) => e.customerId == customerId).toList();
    entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return entries;
  }

  /// A customer's outstanding balance is always derived, never stored —
  /// total charges minus total payments, same as the real schema will be.
  int balanceFor(String customerId) {
    var balance = 0;
    for (final entry in ledgerEntries.where((e) => e.customerId == customerId)) {
      balance += entry.type == LedgerEntryType.charge ? entry.amount : -entry.amount;
    }
    return balance < 0 ? 0 : balance;
  }

  bool hasBalance(SampleCustomer customer) => balanceFor(customer.id) > 0;

  int get totalOutstanding => customers.fold<int>(0, (sum, c) => sum + balanceFor(c.id));

  int get customersWithBalanceCount => customers.where(hasBalance).length;

  SampleCustomer? customerById(String id) {
    final matches = customers.where((c) => c.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  /// Demo-only: appends a payment entry to the sample ledger. No real
  /// ledger_transactions write yet — exists so Record Payment can be
  /// shown working end to end before the real database wiring happens.
  void recordPayment({required String customerId, required int amount, String note = 'Payment received'}) {
    ledgerEntries.insert(
      0,
      SampleLedgerEntry(
        id: 'lg-${_nextEntryId++}',
        customerId: customerId,
        type: LedgerEntryType.payment,
        amount: amount,
        description: note,
        dateTime: DateTime.now(),
      ),
    );
  }
}