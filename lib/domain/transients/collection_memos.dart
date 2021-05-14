import 'package:memo_editor/domain/models/collection.dart';
import 'package:memo_editor/domain/models/memo.dart';

/// Wraps a [collection]'s metadata with its child [memos]
class CollectionMemos {
  CollectionMemos(this.collection, this.memos) : assert(memos.isNotEmpty, 'Must not be an empty list of memos');

  final Collection collection;
  final List<Memo> memos;
}
