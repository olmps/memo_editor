import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo_editor/application/view_models/collection_editor_vm.dart';
import 'package:memo_editor/providers.dart';

final collectionEditorId = ScopedProvider<String>(null);
final collectionEditorVM = StateNotifierProvider.family<CollectionEditorVM, CollectionEditorState, String>(
  (ref, collectionId) => CollectionEditorVMImpl(ref.read(memoServices), collectionId: collectionId),
);

extension CollectionEditorVMContext on BuildContext {
  String get selectedCollectionEditorId => read(collectionEditorId);
  CollectionEditorVM readCollectionEditor() => read(collectionEditorVM(selectedCollectionEditorId).notifier);
}

CollectionEditorState useCollectionEditorState() => useProvider(collectionEditorVM(useProvider(collectionEditorId)));
