import 'package:easysms/easysms.dart';

/// Create a tencent cloud SMS geteway
const Geteway geteway = TencentCloudGeteway(
  appId: '<You Tencent Cloud SMS APP ID>',
  secretId: '<You Tencent Cloud Secret ID>',
  secretKey: '<You Tencent Cloud Secret Key>',
);

/// Create a message
class VerificationCodeNessage extends Message {
  @override
  Future<void> initialize() async {
    // Initialize your message
  }

  @override
  String get content => '<You Message content>';

  @override
  List<String> get data => [
        '<You message data>', /* More data */
      ];

  @override
  String get signName => '<You sign name>';

  @override
  String get template => "<You sms template id>";
}

final Message message = VerificationCodeNessage();

void main() async {
  // Send a message
  final response =
      await geteway.send('<You E.164 formated phone number>', message);

  print(response.body);
}
