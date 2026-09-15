/// Base for every "known, already-friendly" failure. The message here is
/// shown to shop staff directly — plain language only, no technical detail,
/// ever. See AppSpacing/AppTypography note in safe_submit.dart for how this
/// gets surfaced.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class DuplicateImeiException extends AppException {
  DuplicateImeiException(String existingLocation)
      : super(
          'This IMEI is already in the system'
          '${existingLocation.isEmpty ? '' : ' — currently listed under $existingLocation'}.',
        );
}

class CannotDeleteSoldUnitException extends AppException {
  const CannotDeleteSoldUnitException()
      : super("Sold units can't be removed — that would erase real sales history.");
}

class CannotDeleteReservedUnitException extends AppException {
  const CannotDeleteReservedUnitException()
      : super('This unit is reserved for a customer and can\'t be removed yet.');
}

class InvalidPinException extends AppException {
  const InvalidPinException() : super("That PIN doesn't match.");
}

class AccountDeactivatedException extends AppException {
  const AccountDeactivatedException()
      : super('This account is no longer active.');
}

class InvalidImeiException extends AppException {
  const InvalidImeiException() : super('Please scan or type a valid 15-digit IMEI.');
}

class PinMismatchException extends AppException {
  const PinMismatchException() : super("Those PINs don't match — let's try again.");
}

class EmailAlreadyRegisteredException extends AppException {
  const EmailAlreadyRegisteredException()
      : super('An account already exists for that email — try "Existing Shop" instead.');
}

class InvalidShopCredentialsException extends AppException {
  const InvalidShopCredentialsException() : super("That email or password doesn't match our records.");
}

class NoInternetException extends AppException {
  const NoInternetException()
      : super("Couldn't reach the server — check your internet connection and try again.");
}

class PhoneAlreadyRegisteredException extends AppException {
  const PhoneAlreadyRegisteredException()
      : super('A shop is already registered with that phone number.');
}