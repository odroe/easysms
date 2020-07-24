import { Command } from "./command";
import { CloudBasePayload } from "./cloudbase-payload";
import { CloudBaseError } from "./error";
import { VersionCommand } from "./commands/version";
import { init as createCloudBaseApp  } from "@cloudbase/node-sdk";
import { CloudBase } from "@cloudbase/node-sdk/lib/cloudbase";
import { IContext, ICloudBaseConfig } from "@cloudbase/node-sdk/lib/type";

export {Command, CloudBaseError, CloudBasePayload, VersionCommand};

export interface CloudBaseContext extends IContext {
    [name: string]: any;
}

export interface CloudBaseConfig extends ICloudBaseConfig {}

export interface AppConstructor {
    context: CloudBaseContext;
    name: string;
    version?: string;
    config?: CloudBaseConfig;
}

export class Application {
    name: string;
    version: string;
    commands: Map<string, () => Command>;
    context: CloudBaseContext;
    payload?: CloudBasePayload;
    cloudbase: CloudBase;

    constructor({name, context, config, version = 'unknown'}: AppConstructor) {
        this.version = version;
        this.name = name;
        this.context = context;
        this.commands = new Map<string, () => Command>();
        this.cloudbase = createCloudBaseApp(Object.assign({env: context.namespace}, config));

        this.addCommand('version', () => new VersionCommand);
    }


    addCommand(name: string, register: () => Command): void {
        this.commands.set(name, register);
    }

    async run(payload: CloudBasePayload): Promise<any> {
        this.payload = payload;
        const commandRegister = this.commands.get(payload.command);

        if (commandRegister == undefined) {
            return this._notFoundCommand();
        }

        try {
            const command = commandRegister();
            const data = await command.handle(this, payload.data);
            return {
                status: true,
                data,
            };
        } catch (e) {
            return this._catch(e);
        }
    }

    _catch(e: any) {
        let result = {
            status: false,
            code: "unknown" as string | number,
            message: e instanceof Error ? e.message : e,
        };
        if (e instanceof CloudBaseError) {
            result.code = e.code;
        }

        return result;
    }

    _notFoundCommand() {
        return {
            "status": false,
            "code": "unsupported",
            "message": "Unsupported command",
            "supportedCommands": this.commands.keys(),
        };
    }
}
