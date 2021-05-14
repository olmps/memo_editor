import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memo_editor/data/gateways/hive/hive_models.dart' as hive_models;

export 'package:hive/hive.dart' show Box;
export 'package:hive_flutter/hive_flutter.dart' show BoxX;

///  [Hive] boxes
enum HiveBox { collections, memos }

extension on HiveBox {
  String get raw {
    switch (this) {
      case HiveBox.collections:
        return 'collections';
      case HiveBox.memos:
        return 'memos';
    }
  }
}

/// Initialize all [Hive] dependencies by registering all custom type adapters
Future<void> openDatabase() async {
  await Hive.initFlutter();
  // Register all generated type adapters
  Hive..registerAdapter(hive_models.HiveMemoAdapter())..registerAdapter(hive_models.HiveCollectionAdapter());
}

/// Exposes a local key-value database using [Hive]
abstract class HiveDatabase {
  /// Asynchronously retrieves a `Hive` [Box]
  ///
  /// Once a [box] is opened/retrieved with a type [T], this same [T] type must **always** be used for all posterior
  /// calls, that passes the same [box] argument.
  Future<Box<T>> box<T>(HiveBox box);
}

class HiveDatabaseImpl implements HiveDatabase {
  @override
  Future<Box<T>> box<T>(HiveBox box) => Hive.openBox<T>(box.raw);
}
