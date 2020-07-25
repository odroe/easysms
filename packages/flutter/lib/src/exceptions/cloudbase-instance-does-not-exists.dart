/// 当不存在任何 [CloudBase] 环境实例情况下抛出的异常
class CloudBaseInstanceDoesNotExistsException extends Error {
  /// 环境 id
  String envId;

  /// 异常所产生的消息
  String get message =>
      "CloudBase instance${envId == null ? "" : "($envId)"} don't exists.";

  /// 创建一个异常实例。
  ///
  /// [envId] 为当前环境 id
  CloudBaseInstanceDoesNotExistsException([this.envId]);
}
