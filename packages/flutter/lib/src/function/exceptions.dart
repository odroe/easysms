class CloudBaseFunctionCommandResponseDataAssetException
    extends AssertionError {
  CloudBaseFunctionCommandResponseDataAssetException()
      : super('response data don\'t is cloudbase command data.');
}

class CloudBaseFunctionCommandException extends Error {
  final Map<String, dynamic> data;

  bool get status => false;
  String get code => data['code'].toString();
  String get message => data['message'].toString();

  CloudBaseFunctionCommandException(this.data) : super();
}
