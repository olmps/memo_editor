import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memo_editor/data/gateways/hive/hive_models.dart' as hive_models;

export 'package:hive/hive.dart' show Box;
export 'package:hive_flutter/hive_flutter.dart' show BoxX;

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

/// Initialize all [Hive] dependencies by registering all custom type adapters and pre-load all boxes
Future<void> openDatabase() async {
  await Hive.initFlutter();
  Hive..registerAdapter(hive_models.HiveMemoAdapter())..registerAdapter(hive_models.HiveCollectionAdapter());
}

abstract class HiveDatabase {
  /// Synchronously retrieve a previously-loaded `Hive` [Box]
  Future<Box<T>> box<T>(HiveBox box);
}

class HiveDatabaseImpl implements HiveDatabase {
  @override
  Future<Box<T>> box<T>(HiveBox box) => Hive.openBox<T>(box.raw);
}
