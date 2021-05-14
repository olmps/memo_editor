import 'package:memo_editor/domain/models/collection.dart';
import 'package:memo_editor/data/serializers/serializer.dart';
import 'package:memo_editor/domain/models/memo.dart';
import 'package:memo_editor/domain/transients/collection_memos.dart';

class CollectionKeys {
  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const category = 'category';
  static const tags = 'tags';
  static const memos = 'memos';
}

class JsonCollectionMemosSerializer implements Serializer<CollectionMemos, Map<String, dynamic>> {
  final memoSerializer = MemoSerializer();

  @override
  CollectionMemos from(Map<String, dynamic> json) {
    final id = json[CollectionKeys.id] as String;
    final name = json[CollectionKeys.name] as String;
    final description = json[CollectionKeys.description] as String;
    final category = json[CollectionKeys.category] as String;

    final rawTags = json[CollectionKeys.tags] as List;
    final tags = List<String>.from(rawTags);

    final collection = Collection(id: id, name: name, description: description, category: category, tags: tags);

    final rawMemos = List<Map<String, dynamic>>.from(json[CollectionKeys.memos] as List);
    final memos = rawMemos.map(memoSerializer.from).toList();

    return CollectionMemos(collection, memos);
  }

  @override
  Map<String, dynamic> to(CollectionMemos collectionMemos) => <String, dynamic>{
        CollectionKeys.id: collectionMemos.collection.id,
        CollectionKeys.name: collectionMemos.collection.name,
        CollectionKeys.description: collectionMemos.collection.description,
        CollectionKeys.category: collectionMemos.collection.category,
        CollectionKeys.tags: collectionMemos.collection.tags,
        CollectionKeys.memos: collectionMemos.memos.map(memoSerializer.to).toList(),
      };
}

class MemoKeys {
  static const uniqueId = 'uniqueId';
  static const question = 'question';
  static const answer = 'answer';
}

class MemoSerializer implements Serializer<Memo, Map<String, dynamic>> {
  @override
  Memo from(Map<String, dynamic> json) {
    final uniqueId = json[MemoKeys.uniqueId] as String;
    final question = List<Map<String, dynamic>>.from(json[MemoKeys.question] as List);
    final answer = List<Map<String, dynamic>>.from(json[MemoKeys.answer] as List);

    return Memo(uniqueId: uniqueId, question: question, answer: answer);
  }

  @override
  Map<String, dynamic> to(Memo memo) => <String, dynamic>{
        MemoKeys.uniqueId: memo.uniqueId,
        MemoKeys.question: memo.question,
        MemoKeys.answer: memo.answer,
      };
}
