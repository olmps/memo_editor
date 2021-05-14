import 'package:memo_editor/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo_editor/data/gateways/hive/hive_database.dart';
import 'package:memo_editor/data/gateways/hive/hive_models.dart' as hive_models;
import 'package:memo_editor/data/serializers/hive_collection_serializer.dart';
import 'package:memo_editor/domain/models/collection.dart';
import 'package:rxdart/rxdart.dart';

/// Handles all read, write and serialization operations pertaining to one or multiple [Collection]
abstract class CollectionRepository {
  /// Retrieves a [Stream] that contains all stored [Collection]
  ///
  /// The stream updates every time any [Collection] is updated or one is added/removed.
  Future<Stream<List<Collection>>> listenToAllCollections();

  /// Retrieves a collection that matches [collectionId] with [Collection.id]
  Future<Collection> getCollectionById(String collectionId);

  /// Stores a new [Collection]
  ///
  /// If there is a collection with the same [Collection.id], this will update (override) all properties.
  Future<void> putCollection(Collection collection);

  /// Deletes a collection that matches [collectionId] with [Collection.id]
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
