import '../gateway.dart';
import '../strategy.dart';

int _counter = 0;

class OrderStrategy implements Strategy {
  const OrderStrategy();

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
