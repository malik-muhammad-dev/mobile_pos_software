import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_exceptions.dart';

/// The one seam every screen's async action (save, load, delete) routes
/// through. A known AppException surfaces its own plain-language message.
/// Anything unexpected gets one calm fallback message; the real error goes
/// to the debug log only — never to the screen.
///
/// Usage:
///   final result = await safeSubmit(() => repository.addUnit(...));
///   if (result != null) { ... success ... }
Future<T?> safeSubmit<T>(
  Future<T> Function() action, {
  String fallbackMessage = 'Something went wrong. Please try again.',
}) async {
  try {
    return await action();
  } on AppException catch (e) {
    _showError(e.message);
    return null;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('safeSubmit caught unexpected error: $e\n$stackTrace');
    }
    _showError(fallbackMessage);
    return null;
  }
}

void _showError(String message) {
  Get.snackbar(
    '',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 4),
  );
}