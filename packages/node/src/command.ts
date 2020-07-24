import { Application } from ".";

export abstract class Command {
    abstract handle(app: Application, data?: any): any;
}