# Welcome to EasySMS contributing guide

We're glad you've read this far and look forward to making this project a success!

## How to contribute

For gateway contributions, which are single-file, you should create a `/lib/<platform>.dart` file to implement the gateway.

**Note**: do not rely on more third-party packages unless there are special needs. For signatures, if there is no officially maintained signature SDK (depending on it is allowed here), then do not rely on too small third-party implementation packages. You should implement the signature algorithm yourself in your gateway code.

## Reporting bugs

If you find a bug, please report it in the [issue tracker](https://github.com/odroe/easysms/issues/new).
