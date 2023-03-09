import 'package:http/http.dart' as http;

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
    final results = await _withClient((client) async {
      final gateway = await strategy.select(gateways);
      return gateway.send(to, message, client);
    });

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
    final retryResults = await _withClient((client) async {
      final gateway = await strategy.select(availableGateways);

      return gateway.send(failedPhoneNumbers, message, client);
    });

    // Merge results
    return results.followedBy(await _retryFailed(retryResults, message));
  }

  /// With http client
  Future<Iterable<Response>> _withClient<T>(
      Future<Iterable<Response>> Function(http.Client) fn) async {
    final client = http.Client();

    try {
      return await fn(client).timeout(timeout);
    } finally {
      client.close();
    }
  }
}
