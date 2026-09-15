import 'dart:io';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_exceptions.dart';

/// The cloud side of "which shop is this" — separate on purpose from
/// SqliteAuthService's local cashier PINs. This is the shop's own account
/// (email + password, via Supabase Auth), tied to its row in the cloud
/// `shops` table and its subscription. It's what survives a reinstall;
/// cashier PINs don't (see the app_root.dart cold-start flow).
class ShopAccountService extends GetxService {
  SupabaseClient get _client => Supabase.instance.client;

  /// True once this device has ever registered or reactivated a shop —
  /// Supabase persists this session to local storage on its own, so this
  /// stays true across app restarts without any extra code here.
  bool get hasSession => _client.auth.currentSession != null;

  String? get currentUserId => _client.auth.currentUser?.id;

  /// First-run registration: creates the shop's cloud account and its
  /// `shops` row, starting at status = pending_approval (enforced by the
  /// database itself, not by anything this method could get wrong).
  Future<void> registerShop({
    required String shopName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(email: email, password: password);
      final userId = response.user?.id;
      if (userId == null) {
        throw const NoInternetException();
      }
      await _client.from('shops').insert({
        'user_id': userId,
        'name': shopName,
        'phone': phone,
      });
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('already exists')) {
        throw const EmailAlreadyRegisteredException();
      }
      rethrow;
    } on PostgrestException catch (e) {
      // shops.phone has a UNIQUE constraint — a duplicate hits this.
      if (e.code == '23505') {
        throw const PhoneAlreadyRegisteredException();
      }
      rethrow;
    } on SocketException {
      throw const NoInternetException();
    }
  }

  /// Reinstall / new-machine flow: logs back into the existing shop
  /// account. No new `shops` row is created — the existing one (and its
  /// subscription status) is untouched.
  Future<void> reactivateShop({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (_) {
      throw const InvalidShopCredentialsException();
    } on SocketException {
      throw const NoInternetException();
    }
  }

  /// The signed-in shop's own row — RLS guarantees this can never return
  /// another shop's data, even if this code had a bug.
  Future<Map<String, dynamic>?> fetchOwnShopRow() async {
    try {
      final row = await _client.from('shops').select().maybeSingle();
      return row;
    } on SocketException {
      throw const NoInternetException();
    }
  }
}