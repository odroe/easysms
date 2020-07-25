import 'package:cloudbase_database/cloudbase_database.dart' show CloudBaseDatabase;

import 'main.dart' show CloudBase;

export 'package:cloudbase_database/cloudbase_database.dart';

/// 拓展 [database] 获取属性到 [CloudBase] 对象上。
extension CloudBaseExtensionDatabase on CloudBase {
  /// 获取 [CloudBaseDatabase] 对象。
  /// 
  /// Example:
  /// ```
  /// const cloudbase = CloudBase(/* credentials */);
  /// cloudbase.database.collection('posts').limit(12).get();
  /// // Or
  /// const cloudbase = CloudBase(/* credentials */);
  /// conts command = cloudbase.database.command;
  /// ```
  CloudBaseDatabase get database => CloudBaseDatabase(core);
}
