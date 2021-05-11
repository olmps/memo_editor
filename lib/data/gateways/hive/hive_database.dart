import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memo_editor/data/gateways/hive/hive_models.dart' as hive_models;

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
  await Future.wait(HiveBox.values.map((box) => Hive.openBox<dynamic>(box.raw)).toList());
}

abstract class HiveDatabase {
  /// Synchronously retrieve a previously-loaded `Hive` [Box]
  Box box<T>(HiveBox box);
}

class HiveDatabaseImpl implements HiveDatabase {
  @override
  Box box<T>(HiveBox box) {
    if (Hive.isBoxOpen(box.raw)) {
      throw StateError('The box ("$box") was not opened. Make sure to await the `openDatabase` before using Hive.');
    }

    return Hive.box<T>(box.raw);
  }
}
