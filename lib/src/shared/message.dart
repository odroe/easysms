/// Message abstract class.
abstract class Message {
  /// Message initializer.
  ///
  /// This method will be called before sending the message.
  Future<void> initialize();

  /// Get the message content.
  String get content;

  /// Get the message template.
  String get template;

  /// Get the message data.
  List<String> get data;

  /// Get the message sign name.
  String get signName;

  /// Get the message more data.
  Map<String, dynamic> get more => {};
}
