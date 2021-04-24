import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart' as quill_doc;
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo_editor/pages/editor_controller.dart';

enum EditorPopupAction { clearCollection, exportCollection, importCollection }
enum EditorAction { newMemo, switchContent, clearCurrentContent, deleteCurrentMemo }

class EditorPage extends StatefulHookWidget {
  @override
  _EditorPageState createState() => _EditorPageState();
}

const _emptyQuillDoc = <Map<String, dynamic>>[
  <String, dynamic>{'insert': '\n'}
];

class _EditorPageState extends State<EditorPage> {
  QuillController? _currentController;

  final _focusNode = FocusNode();
  final _editorScrollController = ScrollController();
  final _memosListScrollController = ScrollController();

  void _updateListener(BuildContext context, List<Map<String, dynamic>> currentRawDoc) {
    _currentController?.dispose();

    final quill_doc.Document doc;
    if (currentRawDoc.isEmpty) {
      doc = quill_doc.Document.fromJson(_emptyQuillDoc);
      context.read(editorController).currentRawMemo = _emptyQuillDoc;
    } else {
      doc = quill_doc.Document.fromJson(currentRawDoc);
    }

    _currentController = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));

    _currentController!.addListener(() {
      context.read(editorController).currentRawMemo =
          _currentController!.document.toDelta().toJson() as List<Map<String, dynamic>>;
    });
  }

  @override
  void dispose() {
    _currentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = useEditorState();

    final rawQuillDoc = _currentController?.document.toDelta().toJson();
    final isInSyncWithState =
        DeepCollectionEquality().equals(jsonEncode(editorState.currentRawMemo), jsonEncode(rawQuillDoc));

    if (_currentController == null || !isInSyncWithState) {
      _updateListener(context, editorState.currentRawMemo);
    }

    final editor = QuillEditor(
      controller: _currentController!,
      scrollController: _editorScrollController,
      scrollable: true,
      focusNode: _focusNode,
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
        onPressed: () => context.editor.updateCurrentMemoIndex(index),
      ),
    );
    final list = ListView(
      controller: _memosListScrollController,
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
        title: Text('Editando Coleção X'),
        actions: [popupMenu],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: editorActions),
            Scrollbar(
              controller: _memosListScrollController,
              isAlwaysShown: true,
              child: Container(color: Colors.black12, height: 100, child: list),
            ),
            SizedBox(height: 20),
            Text(
              'Editando ${editorState.isShowingQuestion ? 'Questão' : 'Resposta'}',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 20),
            QuillToolbar.basic(controller: _currentController!),
            SizedBox(height: 60),
            editor,
          ],
        ),
      ),
    );
  }

  String _popupActionDescription(EditorPopupAction action) {
    switch (action) {
      case EditorPopupAction.exportCollection:
        return 'Exportar Coleção';
      case EditorPopupAction.importCollection:
        return 'Importar Coleção';
      case EditorPopupAction.clearCollection:
        return 'Deletar Coleção';
    }
  }

  Icon _popupActionIcon(EditorPopupAction action) {
    switch (action) {
      case EditorPopupAction.exportCollection:
        return const Icon(Icons.download_sharp);
      case EditorPopupAction.importCollection:
        return const Icon(Icons.upload_sharp);
      case EditorPopupAction.clearCollection:
        return const Icon(Icons.delete_forever);
    }
  }

  void _popupActionPressed(EditorPopupAction action, BuildContext context) {
    switch (action) {
      case EditorPopupAction.exportCollection:
        // TODO(matuella): allow to select keep changes
        context.editor.exportCollection();
        break;
      case EditorPopupAction.importCollection:
        // TODO(matuella): add a warning, as this is an irreversible action
        context.editor.importCollection();
        break;
      case EditorPopupAction.clearCollection:
        // TODO(matuella): add a warning, as this is an irreversible action
        context.editor.clearCollection();
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
        context.editor.addNewMemo();
        break;
      case EditorAction.switchContent:
        context.editor.switchCurrentMemoContents();
        break;
      case EditorAction.clearCurrentContent:
        context.editor.clearCurrentMemoContents();
        break;
      case EditorAction.deleteCurrentMemo:
        // TODO(matuella): add a warning (only if the content is not blank), as this is an irreversible action
        context.editor.deleteCurrentMemo();
        break;
    }
  }
}

extension on BuildContext {
  EditorController get editor => read(editorController);
}

EditorControllerState useEditorState() => useProvider(editorController.state);
