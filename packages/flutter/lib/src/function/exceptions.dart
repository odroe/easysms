/// 应函数命令数据验证失败所抛出的异常。
///
/// 常用于验证云函数所返回的数据是否是云函数命令 SDK
/// 所返回的消息结构，如果不是则抛出异常。
class CloudBaseFunctionCommandResponseDataAssetException
    extends AssertionError {
  CloudBaseFunctionCommandResponseDataAssetException()
      : super('response data don\'t is cloudbase command data.');
}

/// 云函数命令运行失败抛出的异常
class CloudBaseFunctionCommandException extends Error {
  /// 云函数的 data 数据
  final Map<String, dynamic> data;

  /// 运行状态，固定值 `false`，因为需要抛出
  /// 异常时已经表示运行失败了。
  bool get status => false;

  /// 错误吗
  ///
  /// 云函数命令失败的状态码，常用于判断错误类型。
  String get code => data['code'].toString();

  /// 错误消息
  ///
  /// 云函数命令失败的错误消息，在验证数据时移除
  /// 比较大，比如用户登录时，输入的密码不正确，除
  /// 了用 [code] 进行表示外，[message] 也可以用
  /// 来进行有好消息提示
  String get message => data['message'].toString();

  /// 创建异常实例
  ///
  /// [data] 用于整个异常消息的结构创建。
  CloudBaseFunctionCommandException(this.data) : super();
}
