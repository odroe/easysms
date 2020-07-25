import 'package:flutter_test/flutter_test.dart';

import 'package:cloudbase/cloudbase.dart';

void main() {
  test('adds one to input values', () {
    final credentials = CloudBaseCoreCredentials("", timeout: 10);
    final cloudbase = CloudBase(credentials);

    expect(cloudbase.core.runtimeType, CloudBaseCore);
  });
}
