/// Phone number.
class PhoneNumber {
  /// Country code.
  final int countryCode;

  /// National number.
  final String nationalNumber;

  /// Creates a phone number.
  const PhoneNumber(this.countryCode, this.nationalNumber);

  @override
  String toString() => '$countryCode$nationalNumber';
}
