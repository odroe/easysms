import 'gateway.dart';
import 'message.dart';
import 'phone_number.dart';
import 'response.dart';
import 'strategies/order_strategy.dart';
import 'strategy.dart';

class EasySMS {
  /// Request HTTP timeout
  final Duration timeout;

  /// Current defined gateways
  final Iterable<Gateway> gateways;

  /// Current enabled strategy
  final Strategy strategy;

  /// Creates a new [EasySMS] instance.
  const EasySMS({
    required this.gateways,
    this.strategy = const OrderStrategy(),
    this.timeout = const Duration(seconds: 10),
  });

  /// Sends a message to a phone number.
  Future<Iterable<Response>> send(
      Iterable<PhoneNumber> to, Message message) async {
    final gateway = await strategy.select(gateways);
    final results = await gateway.send(to, message);

    return _retryFailed(results, message);
  }

  /// Retry failed failed.
  ///
  /// Exclude gateways that have failed when selecting a gateway
  /// to send the message.
  Future<Iterable<Response>> _retryFailed(
      Iterable<Response> results, Message message) async {
    final failedResults = results.where((e) => !e.success);
    final availableGateways =
        gateways.where((e) => !failedResults.map((e) => e.gateway).contains(e));

    // If available gateways is empty, return the results
    if (availableGateways.isEmpty) return results;

    // Find failed phone numbers
    final failedPhoneNumbers = failedResults.map((e) => e.to).toSet();

    // Retry failed phone numbers
    final gateway = await strategy.select(availableGateways);
    final retryResults = await gateway.send(failedPhoneNumbers, message);

    // Merge results
    return results.followedBy(await _retryFailed(retryResults, message));
  }
}
