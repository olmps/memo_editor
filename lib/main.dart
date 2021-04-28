import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/pages/editor_page.dart';

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
