import 'package:memo_editor/data/repositories/collection_repository.dart';
import 'package:memo_editor/data/repositories/memo_repository.dart';
import 'package:memo_editor/data/repositories/transfer_repository.dart';
import 'package:memo_editor/domain/models/collection.dart';
import 'package:memo_editor/domain/models/memo.dart';
import 'package:memo_editor/domain/transients/collection_memos.dart';
import 'package:uuid/uuid.dart';

/// Handles all domain-specific operations pertaining to one or multiple [Collection]
abstract class CollectionServices {
  /// {@macro memo_editor.data.repositories.listenToAllCollections}
  Future<Stream<List<Collection>>> listenToAllCollections();

  /// {@macro memo_editor.data.repositories.getCollectionById}
  Future<Collection> getCollectionById(String collectionId);

  /// {@macro memo_editor.data.repositories.putCollection}
  Future<void> putCollection(Collection collection);

  /// {@macro memo_editor.data.repositories.deleteCollectionById}
  Future<void> deleteCollectionById(String collectionId);

  /// Stores a new blank [Collection] and return its instance
  Future<Collection> putPristineCollection();

  /// Imports a single [Collection]
  ///
  /// {@macro memo_editor.data.repositories.importCollectionMemos}
  Future<Collection?> importCollection();

  /// Export a [Collection] of [collectionId] and all of its associated [Memo]
  ///
  /// {@macro memo_editor.data.repositories.exportCollectionMemos}
  Future<void> exportCollectionById(String collectionId);
}

class CollectionServicesImpl implements CollectionServices {
  CollectionServicesImpl(this.collectionRepo, this.memoRepo, this.transferRepo);

  final CollectionRepository collectionRepo;
  final MemoRepository memoRepo;
  final TransferRepository transferRepo;

  static const _uuid = Uuid();

  @override
  Future<void> deleteCollectionById(String collectionId) => collectionRepo.deleteCollectionById(collectionId);

  @override
  Future<Collection> getCollectionById(String collectionId) => collectionRepo.getCollectionById(collectionId);

  @override
  Future<Stream<List<Collection>>> listenToAllCollections() => collectionRepo.listenToAllCollections();

  @override
  Future<void> putCollection(Collection collection) => collectionRepo.putCollection(collection);

  @override
  Future<Collection> putPristineCollection() async {
    final collectionId = _uuid.v4();
    final newCollection = Collection.empty(id: collectionId);

    await Future.wait([
      collectionRepo.putCollection(newCollection),
      memoRepo.putMemo(Memo.empty(uniqueId: _uuid.v4()), collectionId: collectionId),
    ]);

    return newCollection;
  }

  @override
  Future<void> exportCollectionById(String collectionId) async => transferRepo.exportCollectionMemos(
        CollectionMemos(
          await getCollectionById(collectionId),
          await memoRepo.getAllMemos(collectionId: collectionId),
        ),
      );

  @override
  Future<Collection?> importCollection() async {
    final importedCollectionMemos = await transferRepo.importCollectionMemos();
    if (importedCollectionMemos == null) {
      return null;
    }

    await Future.wait([
      collectionRepo.putCollection(importedCollectionMemos.collection),
      memoRepo.putMemos(importedCollectionMemos.memos, collectionId: importedCollectionMemos.collection.id),
    ]);

    return importedCollectionMemos.collection;
  }
}
