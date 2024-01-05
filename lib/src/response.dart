import 'package:webfetch/webfetch.dart' as webfetch;

import 'gateway.dart';
import 'phone_number.dart';

/// EasySMS response.
class Response {
  final Gateway gateway;
  final PhoneNumber to;
  final bool success;
  final webfetch.Response response;

  const Response({
    required this.gateway,
    required this.to,
    required this.success,
    required this.response,
  });

  @override
  String toString() {
    return 'Response${{
      'gateway': gateway,
      'to': to,
      'success': success,
      'response': response,
    }}';
  }
}
