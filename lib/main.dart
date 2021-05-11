import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/application/pages/collection_editor/collection_editor_page.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Memo Editor',
        home: EditorPage(),
      ),
    ),
  );
}
