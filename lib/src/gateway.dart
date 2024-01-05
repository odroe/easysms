import 'message.dart';
import 'phone_number.dart';
import 'response.dart';

/// [EasySMS] gateway.
///
/// The [Gateway] is responsible for generating the [Request]
abstract class Gateway {
  /// Convert a list of phone numbers and a message to a list of requests
  Future<Iterable<Response>> send(Iterable<PhoneNumber> to, Message message);
}
