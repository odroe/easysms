import 'exceptions/empty_gateways_exception.dart';
import 'gateway.dart';

abstract class Strategy {
  /// Select a gateway
  Future<Gateway> select(Iterable<Gateway> gateways);

  /// Returns single gateway if gateways is single, otherwise returns
  /// [or] callback result.
  static Gateway or(
    Iterable<Gateway> gateways, {
    Gateway Function(Iterable<Gateway> gateways)? or,
  }) {
    // If gateways is single, or the [or] callback is null and gateways is not
    // empty, return the first gateway.
    if (gateways.length == 1 || (or == null && gateways.isNotEmpty)) {
      return gateways.first;

      // If or is null, throw [EmptyGatewaysException]
    } else if (or == null) {
      throw const EmptyGatewaysException();
    }

    return or(gateways);
  }
}
