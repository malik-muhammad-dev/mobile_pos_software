import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// PINs are never stored or compared in plain text. Since the schema keeps
/// a single `pin_hash` text column (see staff table), the random salt is
/// packed into that same string as "salt:hash" rather than adding a column.
class PinHash {
  PinHash._();

  static String hash(String pin) {
    final salt = _generateSalt();
    final digest = _digest(pin, salt);
    return '$salt:$digest';
  }

  static bool verify(String pin, String storedHash) {
    final parts = storedHash.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final expected = parts[1];
    return _digest(pin, salt) == expected;
  }

  static String _digest(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt$pin')).toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}