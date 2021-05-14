import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo_editor/application/view_models/collection_details_vm.dart';
import 'package:memo_editor/application/view_models/collections_vm.dart';
import 'package:memo_editor/providers.dart';

final collectionsVM = StateNotifierProvider<CollectionsVM, CollectionsState>(
  (ref) => CollectionsVMImpl(ref.read(collectionServices)),
);

extension CollectionsVMContext on BuildContext {
  CollectionsVM readCollections() => read(collectionsVM.notifier);
}

CollectionsState useCollectionsState() => useProvider(collectionsVM);

final collectionDetailsId = ScopedProvider<String?>(null);
final collectionDetailsVM =
    StateNotifierProvider.autoDispose.family<CollectionDetailsVM, CollectionDetailsState, String?>(
  (ref, collectionId) => CollectionDetailsVMImpl(ref.read(collectionServices), collectionId: collectionId),
);

extension CollectionDetailsVMContext on BuildContext {
  String? get selectedCollectionDetailsId => read(collectionDetailsId);
  CollectionDetailsVM readCollectionDetails() => read(collectionDetailsVM(selectedCollectionDetailsId).notifier);
}

CollectionDetailsState useCollectionDetailsState() =>
    useProvider(collectionDetailsVM(useProvider(collectionDetailsId)));
