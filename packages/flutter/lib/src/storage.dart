import 'package:cloudbase_storage/cloudbase_storage.dart' show CloudBaseStorage;
import 'main.dart' show CloudBase;

export 'package:cloudbase_storage/cloudbase_storage.dart';

/// 拓展 [storage] 获取 [CloudBaseStorage] 对象到
/// [CloudBase] 对象上。
extension CloudBaseExtensionStorage on CloudBase {
  /// 获取 [CloudBaseStorage] 环境下的实例对象
  ///
  /// Example:
  /// ```
  /// const cloudbase = CloudBase(/* credentials */);
  ///
  /// cloudbase.storage.downloadFile('fileId', '/tmp/tmp.file')
  ///   .then(/** You then method */)
  ///   .catch((e) => {/** You catch method */});
  /// ```
  CloudBaseStorage get storage => CloudBaseStorage(core);
}
