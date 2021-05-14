import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart' as quill_doc;
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:memo_editor/application/pages/collection_editor/collection_editor_providers.dart';
import 'package:memo_editor/application/view_models/collection_editor_vm.dart';

enum EditorPopupAction { clearAllMemos }
enum EditorAction { newMemo, switchContent, clearCurrentContent, deleteCurrentMemo }

const _emptyQuillDoc = <Map<String, dynamic>>[
  <String, dynamic>{'insert': '\n'}
];

class CollectionEditorPage extends StatefulHookWidget {
  @override
  State<StatefulWidget> createState() => _CollectionEditorPageState();
}

class _CollectionEditorPageState extends State<CollectionEditorPage> {
  QuillController? _currentController;

  @override
  void dispose() {
    _currentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = useCollectionEditorState();

    if (editorState is! LoadedCollectionEditorState) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rawQuillDoc = _currentController?.document.toDelta().toJson();
    final isInSyncWithState =
        const DeepCollectionEquality().equals(jsonEncode(editorState.currentRawMemo), jsonEncode(rawQuillDoc));

    if (_currentController == null || !isInSyncWithState) {
      _updateListener(context, editorState.currentRawMemo);
    }

    final editor = QuillEditor(
      controller: _currentController!,
      scrollController: useScrollController(),
      scrollable: true,
      focusNode: useFocusNode(),
      autoFocus: false,
      readOnly: false,
      expands: false,
      padding: EdgeInsets.zero,
    );

    final children = List.generate(
      editorState.memosCount,
      (index) => IconButton(
        icon: Text(
          index.toString(),
          style: TextStyle(color: index == editorState.currentMemoIndex ? Colors.blue.shade700 : null),
        ),
        onPressed: () => context.readCollectionEditor().updateCurrentMemoIndex(index),
      ),
    );

    final memosListScrollController = useScrollController();
    final list = ListView(
      controller: memosListScrollController,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: children,
    );

    final popupMenu = PopupMenuButton<EditorPopupAction>(
      onSelected: (action) {
        _popupActionPressed(action, context);
      },
      itemBuilder: (context) {
        return EditorPopupAction.values
            .map(
              (action) => PopupMenuItem(
                value: action,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _popupActionIcon(action),
                    const SizedBox(width: 8),
                    Text(_popupActionDescription(action)),
                  ],
                ),
              ),
            )
            .toList();
      },
    );

    final editorActions = EditorAction.values
        .map(
          (action) => TextButton.icon(
            onPressed: () {
              _editorActionPressed(action, context);
            },
            icon: _editorActionIcon(action),
            label: Text(
              _editorActionDescription(action),
            ),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editando Coleção X'),
        actions: [popupMenu],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: editorActions,
            ),
            Scrollbar(
              controller: memosListScrollController,
              isAlwaysShown: true,
              child: Container(color: Colors.black12, height: 100, child: list),
            ),
            const SizedBox(height: 20),
            Text(
              'Editando ${editorState.isShowingQuestion ? 'Questão' : 'Resposta'}',
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 20),
            QuillToolbar.basic(controller: _currentController!),
            if (editorState.isUpdating) ...[
              const SizedBox(height: 20),
              const SizedBox(
                height: 20,
                child: CircularProgressIndicator(),
              )
            ],
            const SizedBox(height: 60),
            editor,
          ],
        ),
      ),
    );
  }

  void _updateListener(BuildContext context, List<Map<String, dynamic>> currentRawDoc) {
    _currentController?.dispose();

    final quill_doc.Document doc;
    if (currentRawDoc.isEmpty) {
      doc = quill_doc.Document.fromJson(_emptyQuillDoc);
      context.readCollectionEditor().currentRawMemo = _emptyQuillDoc;
    } else {
      doc = quill_doc.Document.fromJson(currentRawDoc);
    }

    _currentController = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));

    _currentController!.addListener(() {
      context.readCollectionEditor().currentRawMemo =
          _currentController!.document.toDelta().toJson() as List<Map<String, dynamic>>;
    });
  }

  String _popupActionDescription(EditorPopupAction action) {
    switch (action) {
      case EditorPopupAction.clearAllMemos:
        return 'Deletar todos os Memos';
    }
  }

  Icon _popupActionIcon(EditorPopupAction action) {
    switch (action) {
      case EditorPopupAction.clearAllMemos:
        return const Icon(Icons.delete_forever);
    }
  }

  void _popupActionPressed(EditorPopupAction action, BuildContext context) {
    switch (action) {
      case EditorPopupAction.clearAllMemos:
        context.readCollectionEditor().clearAllMemos();
        break;
    }
  }

  String _editorActionDescription(EditorAction action) {
    switch (action) {
      case EditorAction.newMemo:
        return 'Novo Memo';
      case EditorAction.switchContent:
        return 'Trocar para Questão/Resposta';
      case EditorAction.clearCurrentContent:
        return 'Limpar Questão/Resposta atual';
      case EditorAction.deleteCurrentMemo:
        return 'Deletar Memo';
    }
  }

  Icon _editorActionIcon(EditorAction action) {
    switch (action) {
      case EditorAction.newMemo:
        return const Icon(Icons.add);
      case EditorAction.switchContent:
        return const Icon(Icons.swap_horiz);
      case EditorAction.clearCurrentContent:
        return const Icon(Icons.clear);
      case EditorAction.deleteCurrentMemo:
        return const Icon(Icons.delete);
    }
  }

  void _editorActionPressed(EditorAction action, BuildContext context) {
    switch (action) {
      case EditorAction.newMemo:
        context.readCollectionEditor().addNewMemo();
        break;
      case EditorAction.switchContent:
        context.readCollectionEditor().switchCurrentMemoContents();
        break;
      case EditorAction.clearCurrentContent:
        context.readCollectionEditor().clearCurrentMemoContents();
        break;
      case EditorAction.deleteCurrentMemo:
        // TODO(matuella): add a warning (only if the content is not blank), as this is an irreversible action
        context.readCollectionEditor().deleteCurrentMemo();
        break;
    }
  }
}
