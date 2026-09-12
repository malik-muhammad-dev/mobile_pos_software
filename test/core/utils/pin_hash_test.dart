import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shop_pos/core/utils/pin_hash.dart';

void main() {
  test('verify succeeds for the correct PIN', () {
    final hash = PinHash.hash('4821');
    expect(PinHash.verify('4821', hash), isTrue);
  });

  test('verify fails for the wrong PIN', () {
    final hash = PinHash.hash('4821');
    expect(PinHash.verify('0000', hash), isFalse);
  });

  test('never stores the PIN itself in the hash string', () {
    final hash = PinHash.hash('4821');
    expect(hash.contains('4821'), isFalse);
  });

  test('same PIN hashed twice produces different strings (random salt)', () {
    final first = PinHash.hash('4821');
    final second = PinHash.hash('4821');
    expect(first, isNot(equals(second)));
  });
}