# CloudBase 快速开发工具

CloudBase 快速开发工具是一个集成云开发函数开发和 Flutter 客户端整合开发的快速工具。

利用函数开发工具进行快速函数开发，并在 Flutter 客户端协同调用的链套工具集。

## 相关工具

- [@bytegem/cloudbase](packages/node) 用于 CloudBase 云函数的开发
- [Flutter package - cloudbase](https://pub.dev/packages/cloudbase) 用于 CloudBase 在 Flutter 下进行开发。

## 样例

云函数 'demo' -> `index.mjs`：
```es6
import { Application, Command } from "@bytegem/cloudbase";

class TestCommand extends Command {
    handle(app, data) {
        console.log(`function name -> ${app.name} \n`);
        console.log('command request data: \n', data, '\n');
        return !!data;
    }
}

export main(event, context) {
    const app = new Application({
        context,
        name: "demo",
    });
    app.addCommand('test', () => new TestCommand);

    return app.run(event);
}
```

在 Flutter 客户端调用云开发的命令：

```dart
import "package:cloudbase/cloudbase.dart";
/// ...
class TestCommand extends CloudBaseFunctionBaseCommand<bool> {
  @override
  String get command => 'test';

  @override
  bool deserializer(data, _) {
    return data == true;
  }

  @override
  String get functionName => 'demo';
}

const bool result = await cloudbase.command(TestCommand());

print(result);
/// ...
```

## TODO

- [x] CloudBase 服务端云函数 SDK
- [x] 云函数集成 CloudBase 官方服务端 SDK
- [x] CloudBase Flutter
- [ ] 网页 SDK
- [ ] 微信小程序 SDK

## LICENSE

[MIT License](LICENSE)
