# CloudBase 快速开发工具

CloudBase 快速开发工具是一个集成云开发函数开发和 Flutter 客户端整合开发的快速工具。

利用函数开发工具进行快速函数开发，并在 Flutter 客户端协同调用的链套工具集。

## 文档

- [安装](https://pub.dev/packages/cloudbase/install)
- [API 参考](https://pub.dev/documentation/cloudbase/latest/cloudbase/cloudbase-library.html)

## 初始化

我们首先在 `lin/main.dart` 的 `main` 函数中初始化 SDK:

```dart
import "package:/cloudbase/cloudbase.dart";

main() {
    // 这里替换为你真实的配置即可
    final security = CloudBaseCoreSecurityCredentials('com.example.example', '1');
    final credentials = CloudBaseCoreCredentials("env id", security: security);

    // 创建一个 CloudBase 实例
    CloudBase.create(credentials);

    /// 其他代码
}
```

## 登录认证

```dart
const auth = CloudBase.instance.auth;
```

参考文档👉[登录认证](https://docs.cloudbase.net/api-reference/flutter/authentication.html)

## 云函数

```dart
const function = CloudBase.instance.function;
```

参考文档👉[云函数](https://docs.cloudbase.net/api-reference/flutter/functions.html)

此外，因为云函数功能单一，我们直接在 CloudBase 单例世行增加了快速调用方法:

```dart
CloudBase.instance.callFunction('function name', {/* params */});
```

## 文件存储

```dart
const storage = CloudBase.instance.storage;
```

参考文档👉[文件存储](https://docs.cloudbase.net/api-reference/flutter/storage.html)


## 数据库

```dart
const database = CloudBase.instance.database;
```

参考文档👉[数据库](https://docs.cloudbase.net/api-reference/flutter/database.html)

## CloudBase 工厂方法

除了使用 `CloudBase.instance` 来获取唯一单例为，我们还有其他单例模式，以满足不同场景需求。

### 创建/初始化/更新单例配置

```dart
const cloudbase = CloudBase(/* credentials */);
```

这个不是工厂函数，而是初始化函数，当缓存中没有当前环境实例是，进行创建，当存在是进行更新到当前最新
常用场景为多环境或者需要动态更新配置的环境。

### 创建/初始化

```dart
const cloudbase = CloudBase.create(/* credentials */);
```

比较是和多环境下使用，这个工厂函数会按照 credentials 信息查询缓存的环境单例，如果存在直接返回，不存在创建后返回。

### 按照环境 ID 获取单例

```dart
const cloudbase = CloudBase.getInstance("You env ID");
```

比较是和多环境情况下使用，从缓存的环境实例中进行获取，如果不存在则抛出一个 `CloudBaseInstanceDoesNotExistsException` 异常。

### 单一环境获取/创建/初始化

```dart
/// 确定已经初始化挥霍创建后获取
/// 如果没有初始化创建，则会抛出一个 CloudBaseInstanceDoesNotExistsException 异常
CloudBase cloudbase = CloudBase.single();

/// 不确定是否创建或初始化进行初始化创建并获取
cloudbase = CloudBase.single(/* credentials */);
```

### 确定已初始化创建，获取唯一单例

```dart
const cloudbase = CloudBase.instance;
```

如果不存在则抛出一个 `CloudBaseInstanceDoesNotExistsException` 异常。

## 云函数命令

在使用了配套的[云函数 SDK 开发工具](../node)时，这将是一个很好的获取选项

### 编写命令

```dart
import "package:cloudbase/cloudbase.dart";

class QueryUserCommand extends CloudBaseFunctionBaseCommand<User> {
  /// 定义云函数命令
  @override
  String get command => 'queryUser';

  /// 设置云函数处理结果数据解码器
  @override
  User deserializer(data, _) => User.formJson(data);

  /// 定义云函数名称
  @override
  String get functionName => 'users';
}
```

### 调用命令

```dart
import "package:cloudbase/cloudbase.dart";

const cloudbase = CloudBase.instance;
const command = QueryUserCommand(1); // 查询用户 ID 为 1 的用户。

try {
    User user = await cloudbase.command(command);

// 也可以不用 on catch 语法，直接在 catch 中进行统一处理。
// 但是推荐使用 on catcb 因为 CloudBaseFunctionCommandException
// 错误是可解析的函数正常错误，而 catch 则为其他错误。没有固定格式而言。
} on CloudBaseFunctionCommandException catch (e) {
    print(e); // 云函数命令返回错误
} catch(e) {
    print(e); // 其他错误
}
```

## LICENSE

[MIT License](../../LICENSE)
