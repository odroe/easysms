library odroe.easysms.tencentcloud;

import 'dart:convert' as convert;

import 'package:crypto/crypto.dart' as crypto;
import 'package:webfetch/webfetch.dart' as webfetch;

import 'easysms.dart';

final _endpoint = Uri.parse('https://sms.tencentcloudapi.com/');
const _method = 'POST';
const _service = 'sms';
const _algorithm = 'TC3-HMAC-SHA256';
final _hash = crypto.sha256;

crypto.Digest _hmacSha256(List<int> key, List<int> data) {
  return crypto.Hmac(_hash, key).convert(data);
}

/// Tencent Cloud SMS Response language.
enum TencentCloudSmsResponseLanguage {
  /// English.
  en('en-US'),

  /// Simplified Chinese.
  zh('zh-CN');

  final String value;
  const TencentCloudSmsResponseLanguage(this.value);
}

/// Tencent Cloud SMS gateway.
class TencentCloudSmsGateway implements Gateway {
  final String secretId;
  final String secretKey;
  final String appId;
  final String region;
  final TencentCloudSmsResponseLanguage language;

  const TencentCloudSmsGateway({
    required this.appId,
    required this.secretId,
    required this.secretKey,
    this.region = 'ap-guangzhou',
    this.language = TencentCloudSmsResponseLanguage.en,
  });

  @override
  Future<Iterable<Response>> send(
      Iterable<PhoneNumber> to, Message message) async {
    final json = await generateJsonBody(to, message);
    final body = convert.json.encode(json);
    final headers = await generateHeaders(body);

    final httpResponse = await webfetch.fetch(
      _endpoint,
      method: _method,
      body: body,
      headers: headers,
    );

    final results = await httpResponse.json() as Map;
    final response = results['Response'] as Map;

    // If contains `Error` returns all phone numbers failed.
    if (response.containsKey('Error')) {
      return to.map((e) => Response(
          gateway: this, to: e, success: false, response: httpResponse));
    }

    final sendStatusSet = (response['SendStatusSet'] as List).cast<Map>();

    return sendStatusSet.map((e) {
      final phoneNumber = to.firstWhere(
          (element) => generatePhoneNumber(element) == e['PhoneNumber']);

      return Response(
        gateway: this,
        to: phoneNumber,
        success: e['Code'] == 'Ok',
        response: httpResponse,
      );
    });
  }

  /// Generate the headers for the request.
  Future<Map<String, String>> generateHeaders(String payload) async {
    final now = DateTime.now();
    final headers = <String, String>{
      ...easySmsDefaultHeaders,
      'Host': _endpoint.host,
      'X-TC-Action': 'SendSms',
      'X-TC-Version': '2021-01-11',
      'X-TC-Region': region,
      'X-TC-Timestamp': generateTimestamp(now),
      'X-TC-Language': language.value,
    };

    return {
      ...headers,
      'Authorization': generateAuthorization(headers, payload, now),
    };
  }

  /// Generate the authorization for the request.
  String generateAuthorization(
      Map<String, String> headers, String payload, DateTime date) {
    final canonicalRequest = generateCanonicalRequest(headers, payload);
    final stringToSign = generateStringToSign(canonicalRequest, date, _service);
    final secretDate = generateSecretDate(date);
    final secretService =
        _hmacSha256(secretDate.bytes, convert.utf8.encode(_service));
    final secretSigning = generateSecretSigning(secretService.bytes);

    // Signature = HexEncode(HMAC_SHA256(SecretSigning, StringToSign))
    final signature =
        _hmacSha256(secretSigning.bytes, convert.utf8.encode(stringToSign))
            .toString();

    // Authorization =
    //  Algorithm + ' ' +
    //  'Credential=' + SecretId + '/' + CredentialScope + ', ' +
    //  'SignedHeaders=' + SignedHeaders + ', ' +
    //  'Signature=' + Signature
    final credentialScope = generateCredentialScope(date, _service);
    final signedHeaders = generateSignedHeaders(headers);
    final paramters = [
      'Credential=$secretId/$credentialScope',
      'SignedHeaders=$signedHeaders',
      'Signature=$signature',
    ].join(', ');

    return '$_algorithm $paramters';
  }

  /// Generate secret signing.
  ///
  /// `SecretSigning = HMAC_SHA256(SecretService, "tc3_request")`
  crypto.Digest generateSecretSigning(List<int> secretService) {
    return _hmacSha256(secretService, convert.utf8.encode('tc3_request'));
  }

  /// Generate the secret date for the request.
  /// `SecretDate = HMAC_SHA256("TC3" + SecretKey, Date)`
  crypto.Digest generateSecretDate(DateTime date) {
    final key = convert.utf8.encode('TC3$secretKey');
    final data = convert.utf8.encode(generateDate(date));

    return _hmacSha256(key, data);
  }

  /// 按如下格式拼接待签名字符串：
  /// ```
  /// StringToSign =
  ///  Algorithm + '\n' +
  ///  RequestTimestamp + '\n' +
  ///  CredentialScope + '\n' +
  ///  HashedRequestPayload
  /// ```
  ///
  /// 其中：
  ///  - Algorithm：签名算法，目前固定为 TC3-HMAC-SHA256。
  ///  - RequestTimestamp：请求时间戳，即请求头部的公共参数 `X-TC-Timestamp` 取值，
  ///    取当前时间 UNIX 时间戳，精确到秒。此示例取值为 `1551113065`。
  ///  - CredentialScope: 凭证范围，格式为 `Date/service/tc3_request`,
  ///    包含日期、所请求的服务和终止字符串（tc3_request）。
  ///    - Date: 为 UTC 标准时间的日期，取值需要和公共参数 X-TC-Timestamp 换算的 UTC
  ///      标准时间日期一致；
  ///    - service：为产品名，必须与调用的产品域名一致。
  ///      此示例计算结果是 `2019-02-25/cvm/tc3_request`。
  ///    - tc3_request：终止字符串，固定为 `tc3_request`。
  ///  - HashedRequestPayload：前述步骤拼接所得规范请求串的哈希值，计算伪代码为:
  ///    ```text
  ///    Lowercase(HexEncode(Hash.SHA256(CanonicalRequest)))
  ///    ```
  ///    此示例计算结果为:
  ///    ```text
  ///    35e9c5b0e3ae67532d3c9f17ead6c90222632e5b1ff7f6e89887f1398934f064
  ///    ```
  ///
  /// 根据以上规则，示例中得到的待签名字符串如下：
  /// ```text
  /// TC3-HMAC-SHA256
  /// 1551113065
  /// 2019-02-25/cvm/tc3_request
  /// 7019a55be8395899b900fb5564e4200d984910f34794a27cb3fb7d10ff6a1e84
  /// ```
  String generateStringToSign(
      String canonicalRequest, DateTime date, String service) {
    final requestTimestamp = generateTimestamp(date);
    final credentialScope = generateCredentialScope(date, service);
    final hashedRequestPayload = generateHashedRequestPayload(canonicalRequest);

    return [
      _algorithm,
      requestTimestamp,
      credentialScope,
      hashedRequestPayload,
    ].join('\n');
  }

  /// 凭证范围，格式为 `Date/service/tc3_request`,
  ///    包含日期、所请求的服务和终止字符串（tc3_request）。
  ///    - Date: 为 UTC 标准时间的日期，取值需要和公共参数 X-TC-Timestamp 换算的 UTC
  ///      标准时间日期一致；
  ///    - service：为产品名，必须与调用的产品域名一致。
  ///      此示例计算结果是 `2019-02-25/cvm/tc3_request`。
  ///    - tc3_request：终止字符串，固定为 `tc3_request`。
  String generateCredentialScope(DateTime date, String service) {
    return '${generateDate(date)}/$service/tc3_request';
  }

  /// Generate date string for the request.
  /// Format: `yyyy-MM-DD`.
  /// Example: `2019-02-25`.
  String generateDate(DateTime date) {
    final utc = date.isUtc ? date : date.toUtc();
    return '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
  }

  /// 按如下伪代码格式拼接规范请求串（CanonicalRequest）：
  /// ```
  /// CanonicalRequest =
  ///   HTTPRequestMethod + '\n' +
  ///   CanonicalURI + '\n' +
  ///   CanonicalQueryString + '\n' +
  ///   CanonicalHeaders + '\n' +
  ///   SignedHeaders + '\n' +
  ///   HashedRequestPayload
  /// ```
  ///
  /// Ref https://cloud.tencent.com/document/api/382/52072#1.-.E6.8B.BC.E6.8E.A5.E8.A7.84.E8.8C.83.E8.AF.B7.E6.B1.82.E4.B8.B2
  ///
  /// 根据以上规则，示例中得到的规范请求串如下：
  /// ```
  /// POST
  /// /
  ///
  /// content-type:application/json; charset=utf-8
  /// host:cvm.tencentcloudapi.com
  /// x-tc-action:describeinstances
  ///
  /// content-type;host;x-tc-action
  /// 35e9c5b0e3ae67532d3c9f17ead6c90222632e5b1ff7f6e89887f1398934f064
  /// ```
  String generateCanonicalRequest(Map<String, String> headers, String payload) {
    final httpRequestMethod = _method.toUpperCase();
    final canonicalUri = _endpoint.path;
    final canonicalQueryString = ''; // Is empty for Tencent Cloud SMS.
    final canonicalHeaders = generateCanonicalHeaders(headers);
    final signedHeaders = generateSignedHeaders(headers);
    final hashedRequestPayload = generateHashedRequestPayload(payload);

    return [
      httpRequestMethod,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      hashedRequestPayload,
    ].join('\n');
  }

  /// 请求正文（payload，即 body，此示例为
  /// ```text
  /// {"Limit": 1, "Filters": [{"Values": ["\u672a\u547d\u540d"], "Name": "instance-name"}]}
  /// ```
  /// 的哈希值, 计算伪代码为
  /// ```
  /// Lowercase(HexEncode(Hash.SHA256(RequestPayload)))
  /// ```
  ///
  /// 即对 HTTP 请求正文做 SHA256 哈希，然后十六进制编码，最后编码串转换成小写字母。
  /// 对于 GET 请求，RequestPayload 固定为空字符串。
  ///
  /// 此示例计算结果是
  /// ```
  /// 35e9c5b0e3ae67532d3c9f17ead6c90222632e5b1ff7f6e89887f1398934f064
  /// ```
  String generateHashedRequestPayload(String payload) {
    final bytes = convert.utf8.encode(payload);
    final digest = _hash.convert(bytes);

    return digest.toString().toLowerCase();
  }

  /// 参与签名的头部信息，说明此次请求有哪些头部参与了签名，和 CanonicalHeaders 包含的
  /// 头部内容是一一对应的。content-type 和 host 为必选头部。
  ///
  /// 拼接规则：
  /// 头部 key 统一转成小写；
  /// 多个头部 key（小写）按照 ASCII 升序进行拼接，并且以分号（;）分隔。
  ///
  /// 此示例为 content-type;host;x-tc-action
  String generateSignedHeaders(Map<String, String> headers) {
    final entries = headers.keys.map((e) => e.toLowerCase()).toList()..sort();

    return entries.join(';');
  }

  /// Generate the canonical headers for the request.
  ///
  /// 参与签名的头部信息，至少包含 host 和 content-type 两个头部，也可加入其他头部参与
  /// 签名以提高自身请求的唯一性和安全性，此示例额外增加了接口名头部。
  ///
  /// 拼接规则：
  /// 头部 key 和 value 统一转成小写，并去掉首尾空格，按照 key:value\n 格式拼接；
  /// 多个头部，按照头部 key（小写）的 ASCII 升序进行拼接。
  ///
  /// 此示例计算结果是 content-type:application/json; charset=utf-8\nhost:cvm.tencentcloudapi.com\nx-tc-action:describeinstances\n。
  /// 注意：content-type 必须和实际发送的相符合，有些编程语言网络库即使未指定也会自动添加
  /// charset 值，如果签名时和发送时不一致，服务器会返回签名校验失败。
  ///
  /// https://cloud.tencent.com/document/api/382/52072#1.-.E6.8B.BC.E6.8E.A5.E8.A7.84.E8.8C.83.E8.AF.B7.E6.B1.82.E4.B8.B2
  String generateCanonicalHeaders(Map<String, String> headers) {
    final entries = headers.entries
        .map((e) => MapEntry(e.key.toLowerCase(), e.value.toLowerCase()))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return '${entries.map((e) => '${e.key}:${e.value}').join('\n')}\n';
  }

  /// Generate the timestamp.
  String generateTimestamp(DateTime date) {
    final utc = date.isUtc ? date : date.toUtc();

    return (utc.millisecondsSinceEpoch ~/ 1000).toString();
  }

  /// Generate the JSON body for the request.
  Future<Map<String, dynamic>> generateJsonBody(
      Iterable<PhoneNumber> to, Message message) async {
    return {
      ...await message.toData(this),
      'PhoneNumberSet': to.map((e) => generatePhoneNumber(e)).toList(),
      'SmsSdkAppId': appId,
      'TemplateId': await message.toTemplate(this)
    };
  }

  /// Generate the phone number.
  ///
  /// The phone number must be in the E.164 format.
  String generatePhoneNumber(PhoneNumber phoneNumber) {
    return '+${phoneNumber.countryCode}${phoneNumber.nationalNumber}';
  }
}
