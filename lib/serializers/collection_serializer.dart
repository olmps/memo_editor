import 'package:memo_editor/models/collection.dart';
import 'package:memo_editor/serializers/memo_serializer.dart';
import 'package:memo_editor/serializers/serializer.dart';

class CollectionKeys {
  static const name = 'name';
  static const description = 'description';
  static const category = 'category';
  static const tags = 'tags';
  static const memos = 'memos';
}

class CollectionSerializer implements Serializer<Collection, Map<String, dynamic>> {
  final memoSerializer = MemoSerializer();

  @override
  Collection from(Map<String, dynamic> json) {
    final name = json[CollectionKeys.name] as String;
    final description = json[CollectionKeys.description] as String;
    final category = json[CollectionKeys.category] as String;

    final rawTags = json[CollectionKeys.tags] as List;
    final tags = rawTags.cast<String>();

    final rawMemos = (json[CollectionKeys.memos] as List).cast<Map<String, dynamic>>();
    final memos = rawMemos.map(memoSerializer.from).toList();

    return Collection(name: name, description: description, category: category, tags: tags, memos: memos);
  }

  @override
  Map<String, dynamic> to(Collection collection) => <String, dynamic>{
        CollectionKeys.name: collection.name,
        CollectionKeys.description: collection.description,
        CollectionKeys.category: collection.category,
        CollectionKeys.tags: collection.tags,
        CollectionKeys.memos: collection.memos.map(memoSerializer.to).toList(),
      };
}
