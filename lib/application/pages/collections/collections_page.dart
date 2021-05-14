import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/application/pages/collection_editor/collection_editor_page.dart';
import 'package:memo_editor/application/pages/collection_editor/collection_editor_providers.dart';
import 'package:memo_editor/application/pages/collections/collection_details.dart';
import 'package:memo_editor/application/pages/collections/collections_providers.dart';
import 'package:memo_editor/application/view_models/collections_vm.dart';

class CollectionsPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = useCollectionsState();
    final vm = context.readCollections();

    if (state is! LoadedCollectionsState) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final actions = [
      ElevatedButton(onPressed: vm.createCollection, child: const Text('Nova Coleção')),
      ElevatedButton(onPressed: vm.importCollection, child: const Text('Importar Coleção')),
    ];

    final collectionsList = Column(
      children: [
        Wrap(spacing: 20, children: actions),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _CollectionsListView(
            itemCount: state.collectionsCount,
            itemBuilder: (index) => _CollectionListViewItem(
              collectionName: state.collectionNameAt(index),
              isHighlighted: state.collectionIdAt(index) == state.selectedCollectionId,
            ),
            onTapCollection: vm.toggleCollectionAtIndex,
            onEditCollectionMemos: (index) => _navigateToEditor(context, collectionId: state.collectionIdAt(index)),
            onExportCollection: (index) => vm.exportCollection(collectionId: state.collectionIdAt(index)),
            onDeleteCollection: (index) => vm.deleteCollection(collectionId: state.collectionIdAt(index)),
          ),
        ),
      ],
    );

    Widget buildCollectionDetails() {
      return ProviderScope(
        overrides: [
          collectionDetailsId.overrideWithValue(state.selectedCollectionId),
        ],
        child: CollectionDetails(
          onEditCollectionMemos: () {
            _navigateToEditor(context, collectionId: state.selectedCollectionId!);
          },
          onExportCollection: vm.exportCollection,
          onDeleteCollection: vm.deleteCollection,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Coleções')),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(border: Border.symmetric(vertical: BorderSide())),
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: collectionsList),
              if (state.selectedCollectionId != null) ...[
                const VerticalDivider(width: 2),
                Flexible(flex: 2, child: buildCollectionDetails()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, {required String collectionId}) {
    Navigator.of(context).push<dynamic>(
      MaterialPageRoute<dynamic>(
        builder: (context) {
          return ProviderScope(
            overrides: [collectionEditorId.overrideWithValue(collectionId)],
            child: CollectionEditorPage(),
          );
        },
      ),
    );
  }
}

class _CollectionListViewItem {
  _CollectionListViewItem({required this.collectionName, required this.isHighlighted});

  final String collectionName;
  final bool isHighlighted;
}

class _CollectionsListView extends HookWidget {
  const _CollectionsListView({
    required this.itemCount,
    required this.itemBuilder,
    required this.onTapCollection,
    required this.onEditCollectionMemos,
    required this.onExportCollection,
    required this.onDeleteCollection,
  });

  final int itemCount;
  final _CollectionListViewItem Function(int index) itemBuilder;

  final void Function(int index) onTapCollection;
  final void Function(int index) onEditCollectionMemos;
  final void Function(int index) onExportCollection;
  final void Function(int index) onDeleteCollection;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = itemBuilder(index);

        return ListTile(
          title: Text(item.collectionName.isEmpty ? 'Nova Coleção' : item.collectionName),
          onTap: () => onTapCollection(index),
          selected: item.isHighlighted,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.list_alt),
                onPressed: () => onEditCollectionMemos(index),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.file_upload),
                onPressed: () => onExportCollection(index),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () => onDeleteCollection(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
