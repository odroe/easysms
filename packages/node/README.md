# CloudBase - Node.js

工具用于快速 CloudBase functions 开发，其有时在于类似 Command 环境下的 Node.js 命令开发。

只需要在 `main` 函数中设置即可快速开始。动态注册命令，减少对象实例化的内存小号。

## 区别

之前开发云函数时候，单一职责函数还好，但是多职责函数时候常常使用 `switch case` 从 `event` 对象中获取定制好的一个表达式值，返回不同的函数处理。

另外就是关于实例化后的服务端 SDK 需要每次都传递过去。

## 开始

```js
exports.main = async (event, context) => {
    const app = cloudbase.init({
        env: context.namespace,
    });

    const { action, ...payload } = event;

    switch (action) {
        case "send-code":
            return await sendCode(app, payload);
        case "verify-code":
            return verifyCode(app, payload);
        case "with-code-login":
            return withCodeLogin(app, payload);
    }

    throw new Error(`Don't support action: [${action}]`);
};
```

使用 CloudBase - Node.js 后👉：

```ts
export function main(event: CloudBasePayload, context: CloudBaseContext) {
    const app = new Application({
        context,
        name,
        version,
    });
    app.addCommand('post', () => new PostCommand);
    app.addCommand('like', () => new LikeCommand);

    return app.run(event);
}
```

### 安装

- npm👉 `npm i --save @bytegem/cloudbase`
- Yarn👉 `yarn add @bytegem/cloudbase`

### 使用

我们按照默认的 cjs 方式，创建一个 `index.js`：

```js
const cloudbase = require('@bytegem/cloudbase');

class NewCommand extends cloudbase.Command {
    // 方法前面还可以添加 async 变成异步方法：
    // async handle(app, payload)
    handle(app, payload) {
        console.log(payload);
        return {name: app.name};
    }
}


exports.main = (event, context) {
    const app = new cloudbase.Application({
        context,
        name: "new-function-commander"
    });
    app.addCommand('new', () => new NewCommand);

    return app.run(event);
}
```

如果是 ESM 方式，我们创建一个 `index.mjs`:

```js
import { Application, Command } from "@bytegem/cloudbase";

class NewCommand extends Command {
    // 方法前面还可以添加 async 变成异步方法：
    // async handle(app, payload)
    handle(app, payload) {
        console.log(payload);
        return {name: app.name};
    }
}

export function main(event, context) {
    const app = new Application({
        context,
        name: "new-function-commander"
    });
    app.addCommand('new', () => new NewCommand);

    return app.run(event);
}
```

### 调用

调用和云函数调用方法一致，唯一的区别就是 event 部分需要写成：

```json
{
    "command": "version",
    "data": "", // any
}
```

### 函数返回

我们为了方便客户端解析，针对响应数据做了封装:

```json
{
    "status": false, // true 表示没有错误，正常运行；false 表示错误
    "code": "unsupported", // 仅错误状态出现字段
    "message": "Unsupported command", // 仅错时出现
    "data": ..., // 取决于命令返回的数据类型，仅正确时存在
}
```

可根据 "status" 进行正确与否的判断。

## LICENSE

[MIT License](../../LICENSE)
