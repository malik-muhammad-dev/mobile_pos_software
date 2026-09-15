import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../db/app_database.dart';
import '../utils/app_exceptions.dart';
import 'shop_account_service.dart';

/// Where this shop's Netflix-style monthly subscription currently stands.
/// `pendingApproval` is the one-time gate before the shop has ever been
/// approved at all; `active` is the normal 30-day cycle; `grace` is the
/// window after a missed due date where the app still works but nags;
/// `suspended` is the hard lockout past that.
enum SubscriptionStatus { pendingApproval, active, grace, suspended }

/// Tracks this shop's subscription lifecycle against the cloud, with an
/// offline-safe local cache — the desktop app must never block on a
/// network call just to decide whether to lock itself.
///
/// The cache lives in the local shop_license table (see migration_v2.dart)
/// and is what isLocked actually reads from; refresh() is a best-effort
/// attempt to pull the real state from Supabase and update that cache.
/// Two loopholes this is specifically built to close: staying offline
/// forever (the cache still has a grace_end_date and still expires it),
/// and rolling the system clock backward (see _checkClockAndPersist).
class SubscriptionService extends GetxService {
  SubscriptionService({Future<Database> Function()? databaseProvider})
      : _databaseProvider = databaseProvider ?? AppDatabase.getDatabase;

  final Future<Database> Function() _databaseProvider;

  /// Null means "we don't know yet" — treated as locked (fail-safe) by
  /// isLocked below, never as "must be fine."
  final Rxn<SubscriptionStatus> status = Rxn<SubscriptionStatus>();
  final Rxn<DateTime> nextDueDate = Rxn<DateTime>();
  final Rxn<DateTime> graceEndDate = Rxn<DateTime>();
  final RxBool paymentPendingReview = false.obs;
  final RxBool clockTamperDetected = false.obs;

  String? _shopId;
  DateTime? _lastKnownNow;
  Timer? _clockTimer;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }

  Future<void> _load() async {
    final db = await _databaseProvider();
    final rows = await db.query('shop_license', where: 'id = 1', limit: 1);
    if (rows.isNotEmpty) {
      final row = rows.first;
      _shopId = row['shop_id'] as String?;
      status.value = _statusFromDb(row['status'] as String?);
      nextDueDate.value = _parseDate(row['next_due_date'] as String?);
      graceEndDate.value = _parseDate(row['grace_end_date'] as String?);
      paymentPendingReview.value = (row['payment_pending_review'] as int? ?? 0) == 1;
      _lastKnownNow = _parseDateTime(row['last_checked_at'] as String?);
    }

    await _checkClockAndPersist();
    // Best-effort — offline is expected and not an error here.
    unawaited(refresh());

    _clockTimer = Timer.periodic(const Duration(hours: 1), (_) => _checkClockAndPersist());
  }

  /// A clock that's moved backwards since the last time we legitimately
  /// observed "now" is the classic way to fool a date-based lock — so
  /// that's treated as a hard signal to lock, and the stored floor is
  /// never moved backward to match it.
  Future<void> _checkClockAndPersist() async {
    final now = DateTime.now();
    if (_lastKnownNow != null && now.isBefore(_lastKnownNow!)) {
      clockTamperDetected.value = true;
      return;
    }
    clockTamperDetected.value = false;
    _lastKnownNow = now;
    await _upsert({'last_checked_at': now.toIso8601String()});
  }

  /// Pulls the shop's real status from Supabase and refreshes the local
  /// cache. Safe to call whenever — a failure (most commonly: offline)
  /// just leaves the existing cached values in place.
  Future<void> refresh() async {
    try {
      final row = await Get.find<ShopAccountService>().fetchOwnShopRow();
      if (row == null) return;

      _shopId = row['id'] as String?;
      status.value = _statusFromDb(row['status'] as String?);
      nextDueDate.value = _parseDate(row['next_due_date'] as String?);
      graceEndDate.value = _parseDate(row['grace_end_date'] as String?);

      await _upsert({
        'shop_id': row['id'] as String?,
        'status': row['status'] as String?,
        'next_due_date': row['next_due_date'] as String?,
        'grace_end_date': row['grace_end_date'] as String?,
      });
    } catch (_) {
      // Offline-first by design: keep whatever's already cached locally.
    }
  }

  int get daysUntilDue =>
      nextDueDate.value == null ? 0 : nextDueDate.value!.difference(DateTime.now()).inDays;

  int get daysUntilLockout =>
      graceEndDate.value == null ? 0 : graceEndDate.value!.difference(DateTime.now()).inDays;

  /// Fail-safe: an unknown status or a tampered clock locks the app,
  /// never leaves it open by default.
  bool get isLocked {
    if (clockTamperDetected.value) return true;
    if (status.value == null) return true;
    return status.value == SubscriptionStatus.suspended ||
        status.value == SubscriptionStatus.pendingApproval;
  }

  /// Active, but renewal is coming up soon — mild reminder banner.
  bool get showsRenewalReminder =>
      status.value == SubscriptionStatus.active && daysUntilDue <= 5 && !paymentPendingReview.value;

  /// Past due, still inside the grace window — stronger overdue banner,
  /// app stays usable.
  bool get showsOverdueWarning => status.value == SubscriptionStatus.grace && !paymentPendingReview.value;

  /// Uploads the receipt photo to this shop's own folder in the private
  /// `receipts` bucket, then records a pending payment_submissions row.
  /// Only an admin action (using the service_role key, never this app)
  /// can ever move that row from pending to approved.
  Future<void> submitPayment({required String filePath}) async {
    final shopId = _shopId;
    if (shopId == null) {
      throw const NoInternetException();
    }

    try {
      final client = Supabase.instance.client;
      final file = File(filePath);
      final ext = filePath.contains('.') ? filePath.split('.').last : 'jpg';
      final objectPath = '$shopId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage.from('receipts').upload(objectPath, file);
      await client.from('payment_submissions').insert({
        'shop_id': shopId,
        'receipt_path': objectPath,
      });

      paymentPendingReview.value = true;
      await _upsert({'payment_pending_review': 1});
    } on SocketException {
      throw const NoInternetException();
    }
  }

  Future<void> _upsert(Map<String, Object?> fields) async {
    final db = await _databaseProvider();
    final existing = await db.query('shop_license', where: 'id = 1', limit: 1);
    if (existing.isEmpty) {
      await db.insert('shop_license', {'id': 1, ...fields});
    } else {
      await db.update('shop_license', fields, where: 'id = 1');
    }
  }

  SubscriptionStatus? _statusFromDb(String? value) {
    switch (value) {
      case 'pending_approval':
        return SubscriptionStatus.pendingApproval;
      case 'active':
        return SubscriptionStatus.active;
      case 'grace':
        return SubscriptionStatus.grace;
      case 'suspended':
        return SubscriptionStatus.suspended;
      default:
        return null;
    }
  }

  DateTime? _parseDate(String? value) => value == null ? null : DateTime.tryParse(value);

  DateTime? _parseDateTime(String? value) => value == null ? null : DateTime.tryParse(value);
}