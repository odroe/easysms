import 'package:cloudbase_auth/cloudbase_auth.dart' show CloudBaseAuth;
import 'main.dart' show CloudBase;

export 'package:cloudbase_auth/cloudbase_auth.dart';

/// 拓展 [CloudBaseAuth] 到 [CloudBase]
extension CloudBaseExtensionAuth on CloudBase {
  /// [auth] getter，用于获取 [CloudBaseAuth] 对象，
  /// 获取后的使用方法和官方 SDK 用法一致。
  ///
  /// Example：
  /// ```
  /// const auth = CloudBase.instance.auth;
  ///
  /// auth.signInAnonymously();
  /// ```
  CloudBaseAuth get auth => CloudBaseAuth(this.core);
}
