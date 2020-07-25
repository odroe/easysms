import 'package:cloudbase_core/cloudbase_core.dart' show CloudBaseConfig;

export 'package:cloudbase_core/cloudbase_core.dart';

/// 云函数应用应用安全凭证
class CloudBaseCoreSecurityCredentials {
  /// 安全凭证 Key
  final String key;

  // 安全凭证版本号
  final String version;

  /// 获取凭证
  Map<String, String> get credentials => {
        "key": key,
        "version": version,
      };

  /// 创建一个云函数应用安全凭证
  const CloudBaseCoreSecurityCredentials(this.key, this.version);
}

/// 云函数核心凭证
class CloudBaseCoreCredentials extends CloudBaseConfig {
  /// 创建云函数核心凭证
  ///
  /// [envId] CloudBase 环境 ID
  ///
  /// [timeout] 环境请求超时时间
  ///
  /// [security] 云函数应用应用安全凭证
  CloudBaseCoreCredentials(
    String envId, {
    int timeout,
    CloudBaseCoreSecurityCredentials security,
  }) : super(
          envId: envId,
          env: envId,
          timeout: timeout,
          appAccess: security?.credentials,
        );

  /// Support [envId] or [env] created Credentials.
  ///
  /// return [envId]
  String get envId {
    if (super.envId is String) {
      return super.envId;
    }

    return env;
  }
}
