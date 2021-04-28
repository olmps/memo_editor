import 'package:memo_editor/models/memo.dart';
import 'package:memo_editor/serializers/serializer.dart';

class MemoKeys {
  static const uniqueId = 'uniqueId';
  static const question = 'question';
  static const answer = 'answer';
}

class MemoSerializer implements Serializer<Memo, Map<String, dynamic>> {
  @override
  Memo from(Map<String, dynamic> json) {
    final uniqueId = json[MemoKeys.uniqueId] as String;
    final question = (json[MemoKeys.question] as List).cast<Map<String, dynamic>>();
    final answer = (json[MemoKeys.answer] as List).cast<Map<String, dynamic>>();

    return Memo(uniqueId: uniqueId, question: question, answer: answer);
  }

  @override
  Map<String, dynamic> to(Memo memo) => <String, dynamic>{
        MemoKeys.uniqueId: memo.uniqueId,
        MemoKeys.question: memo.question,
        MemoKeys.answer: memo.answer,
      };
}
