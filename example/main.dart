import 'package:easysms/easysms.dart';
import 'package:easysms/tencentcloud.dart';

void main() async {
  final gateway = TencentCloudSmsGateway(
    appId: '<You app ID>',
    secretId: '<You secret ID>',
    secretKey: '<You secret key>',
  );
  final easysms = EasySMS(
    gateways: [gateway],
  );

  final message = Message.fromValues(
    template: '<You template ID>',
    data: {
      'SignName': "<You sign name>",
      'TemplateParamSet': [
        '<Param 1>',
        '<Param 2>',
        // ...
      ],
    },
  );

  // Change 86 to your country code.
  final phone = PhoneNumber(86, '<You phone number>');
  final response = await easysms.send([phone], message);

  print('Status: ${response.first.success}'); // true or false
}
