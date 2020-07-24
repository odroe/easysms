export class CloudBaseError extends Error {
    code: number | string;

    constructor(code: number | string, message?: string) {
        super(message);
        this.code = code;
    }
}