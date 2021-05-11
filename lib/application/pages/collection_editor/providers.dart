import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo_editor/application/view_models/collection_editor_vm.dart';
import 'package:memo_editor/domain/models/memo.dart';
import 'package:memo_editor/providers.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final editorVM = StateNotifierProvider<CollectionEditorVM, CollectionEditorState>(
  (ref) => CollectionEditorVM(
    Memo.empty(_uuid.v4()),
    services: ref.read(collectionServices),
  ),
);

extension EditorVMContext on BuildContext {
  CollectionEditorVM readEditor() => read(editorVM.notifier);
}

CollectionEditorState useEditorState() => useProvider(editorVM);
