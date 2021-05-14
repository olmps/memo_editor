import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/application/pages/collections/collections_page.dart';
import 'package:memo_editor/providers.dart';

Future<void> main() async {
  final appState = await init();

  runApp(
    ProviderScope(
      overrides: [
        memoServices.overrideWithValue(appState.memoServices),
        collectionServices.overrideWithValue(appState.collectionServices),
      ],
      child: MaterialApp(
        title: 'Memo Editor',
        home: CollectionsPage(),
      ),
    ),
  );
}
