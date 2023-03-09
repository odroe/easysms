import 'package:easysms/easysms.dart';
import 'package:easysms/smsbao.dart';
import 'package:test/test.dart';

void main() {
  final smsbao = SmsBaoGateway(
    username: 'username',
    password: 'password',
  );

  test('authorization md5', () {
    expect(smsbao.authorization, '5f4dcc3b5aa765d61d8327deb882cf99');
  });

  test('isChineseMainland', () {
    final chinaPhoneNumber = PhoneNumber(86, '12345678901');
    final internationalPhoneNumber = PhoneNumber(1, '16354732');

    expect(smsbao.isChineseMainland(chinaPhoneNumber), true);
    expect(smsbao.isChineseMainland(internationalPhoneNumber), false);
  });
}
