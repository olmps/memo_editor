import 'package:memo_editor/data/repositories/memo_repository.dart';
import 'package:memo_editor/domain/models/memo.dart';
import 'package:uuid/uuid.dart';

/// Handles all domain-specific operations pertaining to one or multiple [Memo]
abstract class MemoServices {
  /// {@macro memo_editor.data.repositories.getAllMemos}
  Future<List<Memo>> getAllMemos({required String collectionId});

  /// {@macro memo_editor.data.repositories.deleteAllMemos}
  Future<void> deleteAllMemos({required String collectionId});

  /// {@macro memo_editor.data.repositories.deleteMemoById}
  Future<void> deleteMemoById(String memoId);

  /// {@macro memo_editor.data.repositories.putMemo}
  Future<void> putMemo(Memo memo, {required String collectionId});

  /// Stores a new blank [Memo] and return its instance
  Future<Memo> putPristineMemo({required String collectionId});
}

class MemoServicesImpl implements MemoServices {
  MemoServicesImpl(this.memoRepo);

  static const _uuid = Uuid();
  final MemoRepository memoRepo;

  @override
  Future<void> deleteAllMemos({required String collectionId}) => memoRepo.deleteAllMemos(collectionId: collectionId);

  @override
  Future<void> deleteMemoById(String memoId) => memoRepo.deleteMemoById(memoId);

  @override
  Future<List<Memo>> getAllMemos({required String collectionId}) => memoRepo.getAllMemos(collectionId: collectionId);

  @override
  Future<void> putMemo(Memo memo, {required String collectionId}) => memoRepo.putMemo(memo, collectionId: collectionId);

  @override
  Future<Memo> putPristineMemo({required String collectionId}) async {
    final newMemo = Memo.empty(uniqueId: _uuid.v4());
    await memoRepo.putMemo(newMemo, collectionId: collectionId);
    return newMemo;
  }
}
