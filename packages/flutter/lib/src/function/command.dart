import 'dart:convert' show jsonEncode;

import '../main.dart' show CloudBaseResponse;
import 'exceptions.dart';

/// 云函数 params 构造器
class CloudBaseFunctionCommandParams {
  /// 云函数命令名称
  /// 
  /// 使用云函数服务端 SDK 进行云函数命令开发所标注的名称。
  /// 例如云函数代码：
  /// ```js
  /// app.addCommand('post', () => new PostCommand);
  /// ```
  /// 那么，这个设定值应该为:
  /// ```
  /// @override
  /// String get command => 'post';
  /// ```
  final String command;

  /// 传递给云函数命令的数据
  final dynamic data;

  /// 创建一个命令参数
  /// 
  /// [command] 为命令名称
  /// 
  /// [data] 为需要传递的数据
  const CloudBaseFunctionCommandParams(this.command, [this.data]);

  /// 将命令参数构建为 params 的 `Map` 数据
  Map<String, dynamic> toJson() => {
    "command": command,
    "data": data,
  };

  @override
  String toString() => jsonEncode(toJson());
}

abstract class CloudBaseFunctionBaseCommand<T> {
  /// 当前命令所需要调用的云函数名称。
  /// 
  /// 该名称为云函数名称，即你在云函数列表所看到的名称。
  String get functionName;

  /// 云函数命令名称
  /// 
  /// 使用云函数服务端 SDK 进行云函数命令开发所标注的名称。
  /// 例如云函数代码：
  /// ```js
  /// app.addCommand('post', () => new PostCommand);
  /// ```
  /// 那么，这个设定值应该为:
  /// ```
  /// @override
  /// String get command => 'post';
  /// ```
  String get command;

  /// 需要传递给云函数命令的数据
  /// 
  /// 默认情况下为 `null`，当你需要你传递数据时，这就是个很
  /// 好的选择；大多数时候是需要传递数据的。
  final dynamic data;

  CloudBaseFunctionCommandParams get getParams => CloudBaseFunctionCommandParams(command, data);

  /// 创建一个云函数命令。
  /// 
  /// Example for `CloudBaseFunctionVersionCommand`
  /// ```
  /// cloudbase.command(CloudBaseFunctionVersionCommand());
  /// ```
  const CloudBaseFunctionBaseCommand([this.data]);

  /// 云函数正确处理后的结果解析器。
  /// 
  /// 其中 [T] 为你所期待的解析后数据，如使用
  /// [built_value](https://pub.dev/packages/built_value)
  /// 构建的 `User` 模型，使用方法如下：
  /// ```dart
  /// @override
  /// User deserializer(dynamic json, _) {
  ///   return User.formJson(json as Map<String, dynamic>);
  /// }
  /// ```
  /// 因为我们无法判断服务器返回的 `data` 数据内容到底是什么，所以
  /// 使用 dynamic 来进行接收，当你实现 [deserializer] 时，你已
  /// 经能确保 `data` 基本结构，所以使用 `as` 标志来进行类型转换
  /// 即可。
  /// 
  /// 当然，你也可以放弃从 `data` 中进行数据解析，而是从原始的
  /// [response] 中进行数据的处理，如：
  /// ```dart
  /// @override
  /// String deserializer(_, CloudBaseResponse response) {
  ///   return response.requestId; // 从 response 中获得请求 ID
  /// }
  /// ```
  T deserializer(dynamic data, CloudBaseResponse response);

  /// 获取调用云函数命令后命令返回的数据。
  /// 
  /// 从云函数的 [response] 中进行获取，云函数根据统一封装格式为：
  /// ```json
  /// {
  ///   "status": true, // or bool
  ///   "data":  // any
  /// }
  /// ```
  /// 方法主要验证 [response.data] 是不是上述的 `Map` 结构。
  Map<String, dynamic> getCommandResponseData(CloudBaseResponse response) {
    if (response.data is Map<String, dynamic>) {
      return response.data;
    }

    throw CloudBaseFunctionCommandResponseDataAssetException();
  }

  bool commandResponseDataValidator(Map<String, dynamic> data, [bool withThrow = false]) {
    if (data['status'] == true) {
      return true;
    } else if (withThrow) {
      throw CloudBaseFunctionCommandException(data);
    }

    return false;
  }

  dynamic getCommandResponseVerifiedData(Map<String, dynamic> data)
    => data['data'];

  /// Returns a string representation of this object.
  @override
  String toString() {
    return super.toString() + " - function: $functionName; command: $command;";
  }
}
