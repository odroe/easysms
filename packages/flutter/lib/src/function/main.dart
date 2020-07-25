import 'package:cloudbase_function/cloudbase_function.dart' show CloudBaseFunction;

import '../main.dart' show CloudBase, CloudBaseResponse;
import 'command.dart' show CloudBaseFunctionBaseCommand;

export 'command.dart';
export 'exceptions.dart';

/// 拓展 CloudBase Function 相关方法到 [CloudBase] 对象上。
extension CloudBaseExtensionFunction on CloudBase {
  /// 获取 [CloudBaseFunction] 对象。
  /// 
  /// Example:
  /// ```
  /// const cloudbase = CloudBase(/* credentials */);
  /// cloudbase.function.callFunction('post');
  /// ```
  CloudBaseFunction get function => CloudBaseFunction(core);

  /// 调用云函数方法，[callFunction] 是 [function.callFunction]
  /// 方法的别名使用。
  /// 
  /// 通常我们并不需要获取通过 [function] 方法获取到 `CloudBaseFunction`
  /// 的实例，因为这个实例内容太过单一，只有一个 [callFunction] 方法，所以
  /// 我们直接在 `CloudBase` 上进行云函数调用是一个不错的选择。
  /// 
  /// Example:
  /// ```
  /// const cloudbase = CloudBase(/* credentials */);
  /// cloudbase.callFunction('post');
  /// ```
  Future<CloudBaseResponse> callFunction(String name, [Map<String, dynamic> params]) => function.callFunction(name, params);

  Future<T> command<T>(CloudBaseFunctionBaseCommand<T> command) async {
    CloudBaseResponse response = await callFunction(command.functionName, command.getParams.toJson());
    Map<String, dynamic> data = command.getCommandResponseData(response);
    command.commandResponseDataValidator(data);
    
    return command.deserializer(command.getCommandResponseVerifiedData(data), response);
  }
}