import 'package:memo_editor/data/gateways/hive/hive_models.dart';
import 'package:memo_editor/data/serializers/serializer.dart';
import 'package:memo_editor/domain/models/memo.dart';

class MemoCollectionMetadata {
  MemoCollectionMetadata(this.memo, this.collectionId);

  final Memo memo;
  final String collectionId;
}

class HiveMemoSerializer implements Serializer<MemoCollectionMetadata, HiveMemo> {
  @override
  MemoCollectionMetadata from(HiveMemo hive) => MemoCollectionMetadata(
        Memo(uniqueId: hive.uniqueId, question: hive.question, answer: hive.answer),
        hive.collectionId,
      );

  @override
  HiveMemo to(MemoCollectionMetadata metadata) => HiveMemo(
        uniqueId: metadata.memo.uniqueId,
        collectionId: metadata.collectionId,
        question: metadata.memo.question,
        answer: metadata.memo.answer,
      );
}
