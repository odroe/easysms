# EasySMS

Easy to use, simple configuration can send SMS messages to Phone. Easily expandable gateways, messages customized according to scenarios.

[![pub package](https://img.shields.io/pub/v/easysms.svg)](https://pub.dev/packages/easysms)
[![test](https://github.com/odroe/easysms/actions/workflows/test.yml/badge.svg)](https://github.com/odroe/easysms/actions/workflows/test.yml)

## Installation

This will add a line like this to your packages `pubspec.yaml` (and run an implicit `dart pub get`):

```yaml
dependencies:
  easysms: latest
```

Or install it from the command line:

```shell
dart pub add easysms
```

## Features

- **Gateway**: Support multiple gateways, you can customize the gateway according to your needs.
- **Message**: Support multiple message templates, you can customize the message according to your needs.
- **Universal**: Universal design, no need to write separate handlers for each service provider.
- **Strategy**: Support gateway selection strategy.
- **Retry**: Support gateway and strategy based retry mechanism.

## Sponsors

EasySMS is an [BSD-3 Clause licensed](LICENSE) open source project with its ongoing development made possible entirely by the support of these awesome backers. If you'd like to join them, please consider [sponsoring Odroe development](https://github.com/sponsors/odroe).

<p align="center">
  <a target="_blank" href="https://github.com/sponsors/odroe#sponsors">
    <img alt="sponsors" src="https://github.com/odroe/.github/raw/main/sponsors.svg">
  </a>
</p>

## Usage

```dart
import 'package:easysms/easysms.dart';

final easysms = EasySMS(
  gateways: [...] // Gateway list
);

final message = Message.fromValues(
  template: '<You template ID>',
  data: {
    'SignName': "<You sign name>",
    'TemplateParamSet': [
      '<Param 1>',
      '<Param 2>',
      // ...
    ],
  },
);

main() async {
  final phone = PhoneNumber('<You country code>', '<You phone number>');
  final response = await easysms.send([phone], message);

  print('Status: ${response.first.success}'); // true or false
}
```

## Message

You can create your own scene messages based on the message:

```dart
import 'package:easysms/easysms.dart';

class OneTimePasswordMessage implements Message {
  final String password;
  final Duration ttl;

  OneTimePasswordMessage(this.password, this.ttl);

  @override
  Future<Map<String, dynamic>> toData(Gateway gateway) {
    // ...
  }

  @override
  Future<String> toTemplate(Gateway gateway) {
    // ...
  }

  @override
  Future<String> toText(Gateway gateway) {
    // ...
  }
}
```

### Built-in Message

#### `formValues`

```dart
final message = Message.fromValues(
  text: '<You message text>',
  template: '<You template ID>',
  data: {
    // ...
  },
);
```

#### `fromCallbacks`

```dart
final message = Message.fromCallbacks(
  text: (gateway) async => '<You message text>',
  template: (gateway) async => '<You template ID>',
  data: (gateway) async => {
    // ...
  },
);
```

## Gateways

| Gateway                  | Platform                                                   | Description               |
| ------------------------ | ---------------------------------------------------------- | ------------------------- |
| `TencentCloudSmsGateway` | [Tencent Cloud SMS](https://cloud.tencent.com/product/sms) | Tencent Cloud SMS gateway |
| `SmsBaoGateway`          | [短信宝](https://www.smsbao.com/)                          | 短信宝 SMS gateway        |

**If the platform you need to use is not listed here, you have several ways to support it:**

1. Create an [issue](https://github.com/odroe/easysms/issues/new) to request support for the platform.
2. Create an [pull request](https://github.com/odroe/easysms/pulls) to add support for the platform.
3. You can create a gateway Dart package yourself,
4. You can implement the gateway yourself in your project without telling anyone.

### How to create a gateway

You must depend on the `easysms` package and implement the `Gateway` interface:

```dart
import 'package:easysms/easysms.dart';

class MyGateway implements Gateway {
  @override
  Future<Iterable<Response>> send(
      Iterable<PhoneNumber> to, Message message, http.Client client) async {
        // ...
      }
}
```

You can refer to [all the gateways](/lib/) we have implemented.

## Strategies

EasySMS allows you to customize the gateway selection strategy.

```dart
class MyStrategy implements Strategy {
  @override
  Future<Gateway> select(Iterable<Gateway> gateways) async {
    // ...
  }
}
```

We implemented a built-in strategy, for example, you can use the `OrderStrategy`:

```dart
final easysms = EasySMS(
  gateways: [...],
  strategy: const OrderStrategy(),
);
```

**Note**: The `OrderStrategy` will select the gateway in the order of the gateway list.

## Contributing

We welcome contributions! Please read our [contributing guide](CONTRIBUTING.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes to EasySMS.

Thank you to all the people who already contributed to Odroe!

[![Contributors](https://opencollective.com/openodroe/contributors.svg?width=890)](https://github.com/odroe/prisma-dart/graphs/contributors)

## Stay in touch

- [Website](https://odroe.com)
- [Twitter](https://twitter.com/odroeinc)
- [Discord](https://discord.gg/r27AjtUUbV)
