import 'package:memo_editor/data/gateways/hive/hive_database.dart';
import 'package:memo_editor/data/gateways/hive/hive_models.dart' as hive_models;
import 'package:memo_editor/data/serializers/hive_memo_serializer.dart';
import 'package:memo_editor/domain/models/memo.dart';

/// Handles all read, write and serialization operations pertaining to one or multiple [Memo]
abstract class MemoRepository {
  /// {@template memo_editor.data.repositories.getAllMemos}
  /// Retrieve all stored [Memo] that are associated with a `Collection` of [collectionId]
  /// {@endtemplate}
  Future<List<Memo>> getAllMemos({required String collectionId});

  /// {@template memo_editor.data.repositories.deleteAllMemos}
  /// Delete all stored [Memo] that are associated with a `Collection` of [collectionId]
  /// {@endtemplate}
  Future<void> deleteAllMemos({required String collectionId});

  /// {@template memo_editor.data.repositories.deleteMemoById}
  /// Delete a single [Memo] of [memoId]
  /// {@endtemplate}
  Future<void> deleteMemoById(String memoId);

  /// {@template memo_editor.data.repositories.putMemo}
  /// Stores a new [Memo]
  ///
  /// If there is a memo with the same [Memo.uniqueId], this will update (override) all of its properties.
  /// {@endtemplate}
  Future<void> putMemo(Memo memo, {required String collectionId});

  /// Stores a list of [Memo]
  ///
  /// All memos that already have a existant counterpart with the same [Memo.uniqueId], will have all of its respective
  /// properties updated (or overridden).
  Future<void> putMemos(List<Memo> memos, {required String collectionId});
}

class MemoRepositoryImpl implements MemoRepository {
  MemoRepositoryImpl(this._hiveDb);

  final HiveMemoSerializer hiveMemoSerializer = HiveMemoSerializer();
  final HiveDatabase _hiveDb;

  @override
  Future<List<Memo>> getAllMemos({required String collectionId}) async {
    final memosBox = await _getMemosBox();
    return memosBox.values
        .where((memo) => memo.collectionId == collectionId)
        .map(hiveMemoSerializer.from)
        .map((metadata) => metadata.memo)
        .toList();
  }

  @override
  Future<void> deleteAllMemos({required String collectionId}) async {
    final memosBox = await _getMemosBox();
    final memoKeys =
        memosBox.values.where((memo) => memo.collectionId == collectionId).map((memo) => memo.uniqueId).toList();

    return memosBox.deleteAll(memoKeys);
  }

  @override
  Future<void> deleteMemoById(String memoId) async => (await _getMemosBox()).delete(memoId);

  @override
  Future<void> putMemo(Memo memo, {required String collectionId}) async {
    final memosBox = await _getMemosBox();
    final hiveMemo = hiveMemoSerializer.to(MemoCollectionMetadata(memo, collectionId));
    return memosBox.put(hiveMemo.uniqueId, hiveMemo);
  }

  @override
  Future<void> putMemos(List<Memo> memos, {required String collectionId}) async {
    final memosBox = await _getMemosBox();
    final hiveMemosEntries = memos.map((memo) => MapEntry(
          memo.uniqueId,
          hiveMemoSerializer.to(MemoCollectionMetadata(memo, collectionId)),
        ));
    return memosBox.putAll(Map<String, hive_models.HiveMemo>.fromEntries(hiveMemosEntries));
  }

  Future<Box<hive_models.HiveMemo>> _getMemosBox() => _hiveDb.box(HiveBox.memos);
}
