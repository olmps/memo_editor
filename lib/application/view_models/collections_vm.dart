import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo_editor/domain/models/collection.dart';
import 'package:memo_editor/domain/services/collection_services.dart';
import 'package:meta/meta.dart';

abstract class CollectionsVM extends StateNotifier<CollectionsState> {
  CollectionsVM(CollectionsState state) : super(state);

  /// Creates a new pristine collection
  ///
  /// After creating this new collection, this same instance is automatically selected.
  Future<void> createCollection();

  /// Exports a collection
  ///
  /// If [collectionId] argument is passed, exports the collection with the respective id, otherwise, exports the
  /// currently selected collection.
  ///
  /// Throws a [InconsistentStateError] if none are present
  Future<void> exportCollection({String? collectionId});

  /// Imports a new collection
  ///
  /// After importing this new collection, this same instance is automatically selected.
  Future<void> importCollection();

  /// Deletes a collection
  ///
  /// If [collectionId] argument is passed, deletes the collection with the respective id, otherwise, deletes the
  /// currently selected collection.
  ///
  /// Throws a [InconsistentStateError] if none are present
  Future<void> deleteCollection({String? collectionId});

  /// Toggles the current selected collection
  ///
  /// If the collection at [index] is already selected, de-selects this same instance, otherwise, selects the one
  /// present in [index]
  void toggleCollectionAtIndex(int index);
}

class CollectionsVMImpl extends CollectionsVM {
  CollectionsVMImpl(this._collectionServices) : super(LoadingCollectionsState()) {
    _addCollectionsListener();
  }

  final CollectionServices _collectionServices;
  StreamSubscription? _listener;

  /// Returns the current [state] type-casted (forced) to a [LoadedCollectionsState]
  LoadedCollectionsState get _loadedState => state as LoadedCollectionsState;

  @override
  Future<void> createCollection() async {
    final newCollection = await _collectionServices.putPristineCollection();
    state = _loadedState.copyOverridingSelectedCollectionId(newCollection.id);
  }

  @override
  Future<void> exportCollection({String? collectionId}) {
    final normalizedCollectionId = _getCollectionIdWithFallback(collectionId);
    return _collectionServices.exportCollectionById(normalizedCollectionId);
  }

  @override
  Future<void> importCollection() async {
    final importedCollection = await _collectionServices.importCollection();
    if (importedCollection == null) {
      return;
    }

    state = _loadedState.copyOverridingSelectedCollectionId(importedCollection.id);
  }

  @override
  Future<void> deleteCollection({String? collectionId}) async {
    final normalizedCollectionId = _getCollectionIdWithFallback(collectionId);

    await _collectionServices.deleteCollectionById(normalizedCollectionId);
    state = _loadedState.copyOverridingSelectedCollectionId(null);
  }

  @override
  void toggleCollectionAtIndex(int index) {
    final collectionId = _loadedState.collectionIdAt(index);

    // Toggles the current selected collection if we are selecting the same already-selected collection
    final isUnselecting = collectionId == _loadedState.selectedCollectionId;
    state = _loadedState.copyOverridingSelectedCollectionId(isUnselecting ? null : collectionId);
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  /// Retrieves the [collectionId] argument fallbacking to the current loaded state's `selectedCollectionId`
  ///
  /// If none are present, throws a [InconsistentStateError.viewModel].
  String _getCollectionIdWithFallback(String? collectionId) {
    var normalizedCollectionId = collectionId;

    final selectedCollectionId = _loadedState.selectedCollectionId;
    normalizedCollectionId ??= selectedCollectionId;

    if (normalizedCollectionId == null) {
      throw InconsistentStateError.viewModel(
          'Trying to delete a collection without sending the specific `collectionId` or having one already selected');
    }

    return normalizedCollectionId;
  }

  Future<void> _addCollectionsListener() async {
    final collectionsStream = await _collectionServices.listenToAllCollections();

    _listener = collectionsStream.listen((collections) {
      final currentState = state;
      if (currentState is LoadedCollectionsState) {
        state = currentState.copyWith(collections: collections);
      } else {
        state = LoadedCollectionsState(collections);
      }
    });
  }
}

abstract class CollectionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingCollectionsState extends CollectionsState {}

class LoadedCollectionsState extends CollectionsState {
  LoadedCollectionsState(this._collections, {this.selectedCollectionId});

  @protected
  final List<Collection> _collections;

  final String? selectedCollectionId;

  int get collectionsCount => _collections.length;

  String collectionIdAt(int index) => _collections[index].id;
  String collectionNameAt(int index) => _collections[index].name;
  String collectionDescriptionAt(int index) => _collections[index].description;
  String collectionCategoryAt(int index) => _collections[index].category;

  @protected
  LoadedCollectionsState copyWith({
    List<Collection>? collections,
    String? selectedCollectionId,
  }) =>
      LoadedCollectionsState(
        collections ?? _collections,
        selectedCollectionId: selectedCollectionId ?? this.selectedCollectionId,
      );

  @protected
  LoadedCollectionsState copyOverridingSelectedCollectionId(String? selectedCollectionId) =>
      LoadedCollectionsState(_collections, selectedCollectionId: selectedCollectionId);

  @override
  List<Object?> get props => [_collections, selectedCollectionId];
}
