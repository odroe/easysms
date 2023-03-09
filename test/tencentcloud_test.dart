import 'package:easysms/tencentcloud.dart';
import 'package:test/test.dart';

/// See https://cloud.tencent.com/document/api/382/52072
void main() {
  late TencentCloudSmsGateway gateway;
  setUpAll(() {
    gateway = TencentCloudSmsGateway(
      appId: 'appId',
      secretId: 'AKIDz8krbsJ5yKBZQpn74WFkmLPx3*******',
      secretKey: 'Gu5t9xGARNpq86cd98joQYCN3*******',
    );
  });

  const headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Host': 'cvm.tencentcloudapi.com',
    'X-TC-Action': 'DescribeInstances',
  };
  const payload =
      r'{"Limit": 1, "Filters": [{"Values": ["\u672a\u547d\u540d"], "Name": "instance-name"}]}';

  const canonicalRequest = r'''
POST
/

content-type:application/json; charset=utf-8
host:cvm.tencentcloudapi.com
x-tc-action:describeinstances

content-type;host;x-tc-action
35e9c5b0e3ae67532d3c9f17ead6c90222632e5b1ff7f6e89887f1398934f064
''';

  test('generateCanonicalRequest', () {
    final result = gateway.generateCanonicalRequest(headers, payload);
    expect(result, canonicalRequest.trim());
  });

  test('generateHashedRequestPayload', () {
    final result = gateway.generateHashedRequestPayload(payload);
    expect(result,
        '35e9c5b0e3ae67532d3c9f17ead6c90222632e5b1ff7f6e89887f1398934f064');
  });
}
