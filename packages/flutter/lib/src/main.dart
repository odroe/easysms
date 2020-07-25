import 'core.dart' show CloudBaseCore, CloudBaseCoreCredentials;
import 'exceptions/exceptions.dart';

export 'auth.dart';
export 'core.dart';
export 'storage.dart';
export 'function/main.dart';
export 'exceptions/exceptions.dart';

class CloudBase {
  /// 缓存当前 [envId] 下的 CloudBase 实例
  static Map<String, CloudBase> _instances = {};

  /// 存储 CloudBase 核心实例
  CloudBaseCore _core;

  /// 获取 CloudBase 核心实例
  CloudBaseCore get core => _core;

  /// 创建当前核心实例
  CloudBase._(this._core);

  /// 单例工厂创建或者获取 CloudBase 实例
  ///
  /// 在 [credentials.envId] 不变的情况下，始终获取单例,
  /// 不会创建实例，目前这么设计的原因是 [CloudBaseCore] 内
  /// 部进行了该实现。
  ///
  /// 使用方法:
  /// ```dart
  /// const credentials = CloudBaseCoreCredentials(
  ///   envId: "You env id",
  ///   /* more... */
  /// );
  /// const cloudbase = CloudBase(credentials);
  /// ```
  factory CloudBase(CloudBaseCoreCredentials credentials) {
    return _instances.putIfAbsent(
        credentials.envId, () => CloudBase._(CloudBaseCore(credentials)));
  }

  /// 通过 [envId] 获取已经存在的实例。
  ///
  /// 方法不会创建新的实例进行缓存，而是从缓存的实例中进行判断，如
  /// 果存在实例，则直接返回。否则将抛出一个 [CloudBaseInstanceDoesNotExists]
  /// 错误，开发者可以接受该错误判断是否需要进行实例创建。
  ///
  /// 常用地方为页面深处，因为一般都是在启动的 main 函数中进行了
  /// SDK 的初始化，然后以供后续使用。
  ///
  /// Example:
  /// ```
  /// CloudBase.getInstance("You env ID");
  /// ```
  factory CloudBase.getInstance(String envId) {
    if (_instances.containsKey(envId)) {
      return _instances[envId];
    }

    throw CloudBaseInstanceDoesNotExists(envId);
  }

  /// 从 CloudBase 单例缓存中获取对象
  ///
  /// 大多数时候推荐使用这个方法，因为大多数时候我们进行应用开发
  /// 时，只使用一个 CloudBase 云开发环境，需要使用多个环境的情
  /// 况比较少。
  ///
  /// 我们在 main 函数或者其他入口进行初始化的时候或者第一次获取
  /// CloudBase 对象也可以使用这个方法，传递参数为 [credentials]
  ///
  /// 例如：
  /// ```
  /// const credentials = CloudBaseCoreCredentials(
  ///   envId: "You env id",
  ///   /* more... */
  /// );
  /// const cloudbase = CloudBase.single(credentials);
  /// ```
  ///
  /// 我们后续使用方法则不在需要传递 [credentials] 可直接获取到对象:
  /// ```
  /// const cloudbase = CloudBase.single();
  /// ```
  ///
  /// 单个后续使用我们更推荐使用 [CloudBase.instance] 方法：
  /// ```
  /// const cloudbase = CloudBase.instance;
  /// ```
  factory CloudBase.single([CloudBaseCoreCredentials credentials]) {
    final CloudBase instance = _instances.values.whereType<CloudBase>().last;
    if (instance != null && instance is CloudBase) {
      return instance;
    } else if (credentials is CloudBaseCoreCredentials) {
      return CloudBase(credentials);
    }

    throw CloudBaseInstanceDoesNotExists('single');
  }

  /// 获取唯一 CloudBase 单例。
  ///
  /// 这个 getter 只是 [CloudBase.single] 的一个别名，使用
  /// 区别在于，[CloudBase.single] 以方法调用形式进行，可进行
  /// 单例的创建，而  [CloudBase.instance] 只是用于获取单例。
  /// 并且是以静态属性读取的方式进行
  ///
  /// 使用 [CloudBase.single] 方式为：
  /// ```
  /// const cloudbase = CloudBase.single();
  /// ```
  /// 而使用 [CloudBase.instance] 则为：
  /// ```
  /// const cloudbase = CloudBase.instance;
  /// ```
  static CloudBase get instance => CloudBase.single();
}
