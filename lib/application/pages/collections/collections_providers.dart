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

final collectionDetailsId = ScopedProvider<String?>((_) => null);
// This should be called using `StateNotifierProvider.autoDispose.family`, but there are issues with dart2js:
// https://github.com/rrousselGit/river_pod/issues/71
// https://github.com/dart-lang/sdk/issues/41449
// Even though they are closed, I think it still didn't rolled out to Flutter, because in Flutter 2.0.6 it still fails
final collectionDetailsVM =
    AutoDisposeStateNotifierProviderFamily<CollectionDetailsVM, CollectionDetailsState, String?>(
  (ref, collectionId) => CollectionDetailsVMImpl(ref.read(collectionServices), collectionId: collectionId),
);

extension CollectionDetailsVMContext on BuildContext {
  String? readSelectedCollectionDetailsId() => read(collectionDetailsId);
  CollectionDetailsVM readCollectionDetails() => read(collectionDetailsVM(readSelectedCollectionDetailsId()).notifier);
}

CollectionDetailsState useCollectionDetailsState() =>
    useProvider(collectionDetailsVM(useProvider(collectionDetailsId)));
