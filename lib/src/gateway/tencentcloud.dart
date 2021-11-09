import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';

import '../shared/message.dart';
import '../shared/getway.dart';

/// Tencent Cloud SMS geteway.
///
/// Send SMS using Tencent Cloud SMS.
/// https://cloud.tencent.com/document/product/382/3784
///
/// Example:
/// ```dart
/// import 'package:easysms/easysms.dart';
///
/// void main() async {
///    final getway = TencentCloudGetway(
///        appId: '<You SMS App ID>',
///        secretId: '<You SMS Secret ID>',
///        secretKey: '<You SMS Secret Key>',
///    );
///   getway.send(<Your Phone Number>, <Message>);
/// }
/// ```
class TencentCloudGeteway implements Geteway {
  /// Tencent Cloud secret ID.
  final String secretId;

  /// Tencent Cloud secret Key.
  final String secretKey;

  /// Tencent Cloud SMS App ID.
  final String appId;

  /// Tencent Cloud SMS region.
  ///
  /// Default is `ap-guangzhou`.
  final String region;

  /// Endpoint if you want to use a custom endpoint.
  ///
  /// Default is `https://sms.tencentcloudapi.com`.
  /// if is `true` then use `https://sms.<region>.tencentcloudapi.com`.
  final bool useNearby;

  /// Create a new Tencent Cloud SMS geteway.
  ///
  /// * [secretId] Tencent Cloud secret ID.
  /// * [secretKey] Tencent Cloud secret Key.
  /// * [appId] Tencent Cloud SMS App ID.
  /// * [region] Tencent Cloud SMS region.
  /// * [useNearby] Endpoint if you want to use a custom endpoint.
  const TencentCloudGeteway({
    required this.appId,
    required this.secretId,
    required this.secretKey,
    this.region = 'ap-guangzhou',
    this.useNearby = false,
  });

  /// Tencent Cloud SMS endpoint.
  String get endpoint =>
      useNearby ? 'sms.$region.tencentcloudapi.com' : 'sms.tencentcloudapi.com';

  @override
  Future<Response> send(String phoneNumber, Message message) async {
    await message.initialize();

    final Map<String, dynamic> request = message.more;
    request['PhoneNumberSet'] = [phoneNumber];
    request['TemplateId'] = message.template;
    request['SignName'] = message.signName;
    request['TemplateParamSet'] = message.data;
    request['SmsSdkAppId'] = appId;

    final DateTime now = DateTime.now();
    final String json = jsonEncode(request);

    // print(_sign(json, now));

    return await post(
      Uri.https(endpoint, '/'),
      headers: {
        'X-TC-Action': 'SendSms',
        'X-TC-Timestamp': (now.millisecondsSinceEpoch ~/ 1000).toString(),
        'X-TC-Version': '2021-01-11',
        'X-TC-Region': region,
        'Host': endpoint,
        'Content-Type': 'application/json',
        'Authorization': _sign(json, now),
        'User-Agent': 'EasySMS',
      },
      body: json,
    );
  }

  /// Sign a request.
  String _sign(String payload, DateTime date) {
    // Get date UTC.
    final DateTime utc = date.toUtc();

    // Get headers stting.
    final String headersString = [
          'content-type:application/json; charset=utf-8',
          'host:$endpoint'
        ].join('\n') +
        '\n';

    final String canonicalRequest =
        'POST\n/\n\n$headersString\ncontent-type;host\n${sha256.convert(utf8.encode(payload)).toString()}';

    // create YYYY-MM-DD date string.
    final String dateStr =
        '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';

    final String stringToSign =
        'TC3-HMAC-SHA256\n${(date.millisecondsSinceEpoch ~/ 1000).toString()}\n$dateStr/sms/tc3_request\n${sha256.convert(utf8.encode(canonicalRequest)).toString()}';

    final Digest secretDate = Hmac(sha256, utf8.encode('TC3' + secretKey))
        .convert(utf8.encode(dateStr));

    final Digest secretService =
        Hmac(sha256, secretDate.bytes).convert(utf8.encode('sms'));

    final Digest secretSigning =
        Hmac(sha256, secretService.bytes).convert(utf8.encode('tc3_request'));

    final Digest signature =
        Hmac(sha256, secretSigning.bytes).convert(utf8.encode(stringToSign));

    return 'TC3-HMAC-SHA256 Credential=$secretId/$dateStr/sms/tc3_request, SignedHeaders=content-type;host, Signature=${signature.toString()}';
  }
}
