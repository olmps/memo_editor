import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo_editor/application/pages/collections/collections_providers.dart';
import 'package:memo_editor/application/view_models/collection_details_vm.dart';

class CollectionDetails extends HookWidget {
  const CollectionDetails({
    required this.onEditCollectionMemos,
    required this.onExportCollection,
    required this.onDeleteCollection,
  });

  final VoidCallback onEditCollectionMemos;
  final VoidCallback onExportCollection;
  final VoidCallback onDeleteCollection;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final state = useCollectionDetailsState();
    final vm = context.readCollectionDetails();

    if (state is! LoadedCollectionDetailsState) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scrollbar(
      controller: scrollController,
      isAlwaysShown: true,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CollectionDetailsForm(
                initialName: state.initialName,
                initialDescription: state.initialDescription,
                initialCategory: state.initialCategory,
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: vm.updateCollection, child: const Text('Salvar')),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: onEditCollectionMemos, child: const Text('Editar Memos')),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: onExportCollection, child: const Text('Exportar Coleção')),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: onDeleteCollection, child: const Text('Deletar Coleção')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionDetailsForm extends HookWidget {
  const _CollectionDetailsForm({
    required this.initialName,
    required this.initialDescription,
    required this.initialCategory,
  });

  final String initialName;
  final String initialDescription;
  final String initialCategory;

  @override
  Widget build(BuildContext context) {
    final vm = context.readCollectionDetails();

    final nameTextController = useTextEditingController(text: initialName);
    final descriptionTextController = useTextEditingController(text: initialDescription);
    final categoryTextController = useTextEditingController(text: initialCategory);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextField(
                  controller: nameTextController,
                  onChanged: vm.updateName,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Flexible(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: null,
                  controller: descriptionTextController,
                  onChanged: vm.updateDescription,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Flexible(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextField(
                  controller: categoryTextController,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  onChanged: vm.updateCategory,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
