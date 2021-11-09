import 'package:http/http.dart';

import 'message.dart';

/// Geteway abscract class.
///
/// This class is used to define the gateway interface.
///
/// Example:
/// ```dart
/// class MyGateway extends Gateway {
///   @override
///   Future<Response> send(String phone, Message message) async {
///     return await post(message.url, body: message.body);
///   }
/// }
/// ```
abstract class Geteway {
  /// Send a message to a phone number.
  ///
  /// This method is used to send a message to a phone number.
  ///
  /// Example:
  /// ```dart
  /// final response = await gateway.send(phone, message);
  /// ```
  ///
  /// - [phone]: The phone number to send the message to. (Using E.164 format)
  /// - [message]: The message to send.
  Future<Response> send(String phone, Message message);
}
