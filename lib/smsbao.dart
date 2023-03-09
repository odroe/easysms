library odroe.easysms.smsbao;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'easysms.dart';

/// 短信宝 gateway.
///
/// API reference: https://www.smsbao.com/openapi
///
/// ## Usage:
/// ```dart
/// import 'package:odroe/easysms/smsbao.dart';
///
/// final smsbao = SmsBaoGateway(
///   username: 'username',
///   password: 'password',
/// );
///
/// final easysms = EasySms(gateways: [smsbao]);
///
/// final result = await easysms.send(...);
/// ```
class SmsBaoGateway implements Gateway {
  /// Endpoint of 短信宝
  static final String endpoint = 'api.smsbao.com';

  /// Your username of smsbao.
  final String username;

  /// Your password of smsbao.
  final String? password;

  /// Your api key of smsbao.
  final String? apiKey;

  /// Your project id of smsbao.
  ///
  /// **Note**: This is only available for china mainland.
  final String? projectId;

  /// Creates a new smsbao gateway.
  ///
  /// You can use either [password] or [apiKey] to authenticate.
  const SmsBaoGateway({
    required this.username,
    this.password,
    this.apiKey,
    this.projectId,
  });

  /// Authorization parameter
  String get authorization {
    // If api key is provided, use it.
    if (apiKey != null) {
      return apiKey!;

      // If password is provided, covert it to md5.
    } else if (password != null) {
      return md5.convert(utf8.encode(password!)).toString();
    }

    // Otherwise, throw an error.
    throw ArgumentError('Either password or apiKey must be provided.');
  }

  @override
  Future<Iterable<Response>> send(
      Iterable<PhoneNumber> to, Message message, http.Client client) async {
    final requests = await groupRequests(to, message);
    print(requests);
    final responses = requests.map<Future<Iterable<Response>>>((e) async {
      final streamedResponse = await client.send(e.key);
      final httpResponse = await http.Response.fromStream(streamedResponse);

      return e.value.map(
        (to) => Response(
          gateway: this,
          to: to,
          success: httpResponse.body == '0',
          response: httpResponse,
        ),
      );
    });

    final results = await Future.wait(responses);

    return results.expand((e) => e);
  }

  /// Groups requests.
  ///
  /// Group Chinese Mainland and international mobile phone numbers.
  Future<Iterable<MapEntry<http.Request, Iterable<PhoneNumber>>>> groupRequests(
      Iterable<PhoneNumber> to, Message message) async {
    final groups = <bool, Set<PhoneNumber>>{
      true: to.where((phone) => isChineseMainland(phone)).toSet(),
      false: to.where((phone) => !isChineseMainland(phone)).toSet(),
    };

    final resutls = groups.entries.map((e) async {
      final url = await generateRequestUrl(e.value, message, e.key);
      final request = http.Request('GET', url);

      return MapEntry(request, e.value);
    });

    return Future.wait(resutls);
  }

  /// Is Chinese Mainland.
  bool isChineseMainland(PhoneNumber phone) {
    return phone.countryCode == 86 && phone.nationalNumber.trim().length == 11;
  }

  /// Generates the request url.
  Future<Uri> generateRequestUrl(
      Iterable<PhoneNumber> to, Message message, bool isChineseMainland) async {
    final queryParameters = <String, String>{
      if (isChineseMainland && projectId != null) 'g': projectId!,
      'm': to.map((e) => generatePhoneNumber(e, isChineseMainland)).join(','),
      'c': await message.toText(this),
      'u': username,
      'p': authorization,
    };
    final path = generatePath(isChineseMainland);

    // Return the request url.
    return Uri.https(endpoint, path, queryParameters);
  }

  /// Generate phone number.
  String generatePhoneNumber(PhoneNumber phone, bool isChineseMainland) {
    if (isChineseMainland) {
      return phone.nationalNumber;
    } else {
      return '+${phone.countryCode}${phone.nationalNumber}';
    }
  }

  /// Generate path.
  String generatePath(bool isChineseMainland) {
    return isChineseMainland ? '/sms' : '/wsms';
  }
}
