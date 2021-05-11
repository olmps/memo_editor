import 'package:memo_editor/domain/models/collection.dart';
import 'package:memo_editor/data/serializers/memo_json_serializer.dart';
import 'package:memo_editor/data/serializers/serializer.dart';

class CollectionKeys {
  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const category = 'category';
  static const tags = 'tags';
}

class CollectionSerializer implements Serializer<Collection, Map<String, dynamic>> {
  final memoSerializer = MemoSerializer();

  @override
  Collection from(Map<String, dynamic> json) {
    final id = json[CollectionKeys.id] as String;
    final name = json[CollectionKeys.name] as String;
    final description = json[CollectionKeys.description] as String;
    final category = json[CollectionKeys.category] as String;

    final rawTags = json[CollectionKeys.tags] as List;
    final tags = rawTags.cast<String>();

    return Collection(id: id, name: name, description: description, category: category, tags: tags);
  }

  @override
  Map<String, dynamic> to(Collection collection) => <String, dynamic>{
        CollectionKeys.name: collection.name,
        CollectionKeys.description: collection.description,
        CollectionKeys.category: collection.category,
        CollectionKeys.tags: collection.tags,
      };
}
