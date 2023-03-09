import '../gateway.dart';
import '../strategy.dart';

class OrderStrategy implements Strategy {
  const OrderStrategy();

  static int _counter = 0;

  @override
  Future<Gateway> select(Iterable<Gateway> gateways) async =>
      Strategy.or(gateways, or: _withCounterSelect);

  /// With counter select gateway.
  Gateway _withCounterSelect(Iterable<Gateway> gateways) {
    /// Get current counter gateway.
    final gateway = gateways.elementAt(_counter);

    // Update counter value.
    _counter = (_counter + 1) % gateways.length;

    return gateway;
  }
}
