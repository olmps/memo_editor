import 'package:memo_editor/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo_editor/data/gateways/hive/hive_database.dart';
import 'package:memo_editor/data/gateways/hive/hive_models.dart' as hive_models;
import 'package:memo_editor/data/serializers/hive_collection_serializer.dart';
import 'package:memo_editor/domain/models/collection.dart';
import 'package:rxdart/rxdart.dart';

/// Handles all read, write and serialization operations pertaining to one or multiple [Collection]
abstract class CollectionRepository {
  /// {@template memo_editor.data.repositories.listenToAllCollections}
  /// Retrieves a [Stream] that updates with all stored [Collection]
  ///
  /// A new event is emitted every time any [Collection] is updated or one is added/removed.
  /// {@endtemplate}
  Future<Stream<List<Collection>>> listenToAllCollections();

  /// {@template memo_editor.data.repositories.getCollectionById}
  /// Retrieves a collection that matches [collectionId] with [Collection.id]
  /// {@endtemplate}
  Future<Collection> getCollectionById(String collectionId);

  /// {@template memo_editor.data.repositories.putCollection}
  /// Stores a new [Collection]
  ///
  /// If there is a collection with the same [Collection.id], this will update (override) all of its properties.
  /// {@endtemplate}
  Future<void> putCollection(Collection collection);

  /// {@template memo_editor.data.repositories.deleteCollectionById}
  /// Deletes a collection that matches [collectionId] with [Collection.id]
  /// {@endtemplate}
  Future<void> deleteCollectionById(String collectionId);
}

class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._hiveDb);

  final HiveCollectionSerializer _hiveCollectionSerializer = HiveCollectionSerializer();
  final HiveDatabase _hiveDb;

  @override
  Future<Stream<List<Collection>>> listenToAllCollections() async {
    final collectionsBox = await _getCollectionsBox();
    List<Collection> _mapCollectionsFromBox() => collectionsBox.values.map(_hiveCollectionSerializer.from).toList();
    // We have to add a starting value because `watch` only updates when a new event has occurred, meaning that this
    // stream will almost always start "empty"
    return collectionsBox.watch().map((_) => _mapCollectionsFromBox()).startWith(_mapCollectionsFromBox());
  }

  @override
  Future<void> putCollection(Collection collection) async {
    final collectionsBox = await _getCollectionsBox();
    return collectionsBox.put(collection.id, _hiveCollectionSerializer.to(collection));
  }

  @override
  Future<void> deleteCollectionById(String collectionId) async => (await _getCollectionsBox()).delete(collectionId);

  @override
  Future<Collection> getCollectionById(String collectionId) async {
    final collectionsBox = await _getCollectionsBox();
    final hiveCollection = collectionsBox.get(collectionId);
    if (hiveCollection == null) {
      throw InconsistentStateError.repository('Trying to get a nonexistent `Collection` of id $collectionId');
    }

    return Future.value(_hiveCollectionSerializer.from(hiveCollection));
  }

  Future<Box<hive_models.HiveCollection>> _getCollectionsBox() => _hiveDb.box(HiveBox.collections);
}
