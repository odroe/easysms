import 'package:cloudbase_core/cloudbase_core.dart' show CloudBaseConfig;

export 'package:cloudbase_core/cloudbase_core.dart';

class CloudBaseCoreSecurityCredentials {
  final String key;
  final String version;

  Map<String, String> get credentials => {
    "key": key,
    "version": version,
  };

  const CloudBaseCoreSecurityCredentials(this.key, this.version);
}

class CloudBaseCoreCredentials extends CloudBaseConfig {
  CloudBaseCoreCredentials(String envId, {
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
