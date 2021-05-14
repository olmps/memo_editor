import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/domain/models/collection.dart';
import 'package:memo_editor/domain/services/collection_services.dart';
import 'package:rxdart/rxdart.dart';

abstract class CollectionDetailsVM extends StateNotifier<CollectionDetailsState> {
  CollectionDetailsVM(CollectionDetailsState state) : super(state);

  /// Retrieves a stream of all events that updates this collection's name
  ///
  /// To update this stream, call [updateName]
  Stream<String> get name;

  /// Validates and emits a new event for the [name] stream
  Function(String) get updateName;

  /// Retrieves a stream of all events that updates this collection's description
  ///
  /// To update this stream, call [updateDescription]
  Stream<String> get description;

  /// Validates and emits a new event for the [description] stream
  Function(String) get updateDescription;

  /// Retrieves a stream of all events that updates this collection's category
  ///
  /// To update this stream, call [updateCategory]
  Stream<String> get category;

  /// Validates and emits a new event for the [category] stream
  Function(String) get updateCategory;

  /// If validated, updates this collection with all of its fields
  Future<void> updateCollection();
}

class CollectionDetailsVMImpl extends CollectionDetailsVM {
  CollectionDetailsVMImpl(this._collectionServices, {this.collectionId}) : super(LoadingCollectionDetailsState()) {
    _loadCollection();
  }

  final CollectionServices _collectionServices;
  final String? collectionId;

  late final Collection _collection;

  late final BehaviorSubject<String> _nameController;
  late final BehaviorSubject<String> _descriptionController;
  late final BehaviorSubject<String> _categoryController;

  @override
  Stream<String> get name => _nameController.stream;
  @override
  Stream<String> get description => _descriptionController.stream;
  @override
  Stream<String> get category => _categoryController.stream;

  @override
  Function(String) get updateName => _nameController.sink.add;
  @override
  Function(String) get updateDescription => _descriptionController.sink.add;
  @override
  Function(String) get updateCategory => _categoryController.sink.add;

  @override
  Future<void> updateCollection() async {
    final updatedCollection = _collection.copyWith(
      name: _nameController.value,
      description: _descriptionController.value,
      category: _categoryController.value,
    );

    await _collectionServices.putCollection(updatedCollection);
  }

  @override
  void dispose() {
    _nameController.close();
    _descriptionController.close();
    _categoryController.close();

    super.dispose();
  }

  Future<void> _loadCollection() async {
    if (collectionId != null) {
      _collection = await _collectionServices.getCollectionById(collectionId!);
    } else {
      // If there is no collectionId associated with this details, it means that it's a pristine collection
      _collection = await _collectionServices.putPristineCollection();
    }

    _nameController = BehaviorSubject<String>.seeded(_collection.name);
    _descriptionController = BehaviorSubject<String>.seeded(_collection.description);
    _categoryController = BehaviorSubject<String>.seeded(_collection.category);

    state = LoadedCollectionDetailsState(
      initialName: _collection.name,
      initialDescription: _collection.description,
      initialCategory: _collection.category,
    );
  }
}

abstract class CollectionDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingCollectionDetailsState extends CollectionDetailsState {}

class LoadedCollectionDetailsState extends CollectionDetailsState {
  LoadedCollectionDetailsState({
    required this.initialName,
    required this.initialDescription,
    required this.initialCategory,
  });

  final String initialName;
  final String initialDescription;
  final String initialCategory;
}
