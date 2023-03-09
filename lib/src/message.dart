import 'gateway.dart';

/// Messages to be sent.
abstract class Message {
  /// Returns a text of the message.
  Future<String> toText(Gateway gateway);

  /// Return a template of the message.
  Future<String> toTemplate(Gateway gateway);

  /// Returns a [Map<String, String>] of the message.
  Future<Map<String, dynamic>> toData(Gateway gateway);

  /// Creates a new [Message] instance from callbacks.
  const factory Message.fromCallbacks({
    required Future<String> Function(Gateway gateway) template,
    required Future<String> Function(Gateway gateway) text,
    required Future<Map<String, dynamic>> Function(Gateway gateway) data,
  }) = _CallbackMessage;

  /// Creates a new [Message] instance from values.
  const factory Message.fromValues({
    required String template,
    String text,
    Map<String, dynamic> data,
  }) = _ValueMessage;
}

/// Implementation of [Message] for values.
class _ValueMessage implements Message {
  final String template;
  final String text;
  final Map<String, dynamic> data;

  const _ValueMessage({
    required this.template,
    this.text = '',
    this.data = const {},
  });

  @override
  Future<Map<String, dynamic>> toData(Gateway gateway) async => data;

  @override
  Future<String> toTemplate(Gateway gateway) async => template;

  @override
  Future<String> toText(Gateway gateway) async => text;
}

/// Implantation of [Message] for callbck.
class _CallbackMessage implements Message {
  final Future<String> Function(Gateway gateway) template;
  final Future<String> Function(Gateway gateway) text;
  final Future<Map<String, dynamic>> Function(Gateway gateway) data;

  const _CallbackMessage({
    required this.template,
    required this.text,
    required this.data,
  });

  @override
  Future<Map<String, dynamic>> toData(Gateway gateway) => data(gateway);

  @override
  Future<String> toTemplate(Gateway gateway) => template(gateway);

  @override
  Future<String> toText(Gateway gateway) => text(gateway);
}
