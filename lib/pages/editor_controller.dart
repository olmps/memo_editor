import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/models/collection.dart';
import 'package:memo_editor/models/memo.dart';
import 'package:memo_editor/providers.dart';
import 'package:memo_editor/services/collection_services.dart';

final editorController =
    StateNotifierProvider((ref) => EditorController(const Memo.empty(), services: ref.read(collectionServices)));

class EditorController extends StateNotifier<EditorControllerState> {
  EditorController(Memo initialMemo, {required this.services})
      : _memos = [initialMemo],
        _currentRawMemo = initialMemo.question,
        super(EditorControllerState(
            currentMemoIndex: 0, currentRawMemo: initialMemo.question, memosCount: 1, isShowingQuestion: true));

  final CollectionServices services;

  final List<Memo> _memos;
  List<Map<String, dynamic>> _currentRawMemo;
  List<Map<String, dynamic>> get currentRawMemo => state.currentRawMemo;
  set currentRawMemo(List<Map<String, dynamic>> rawMemo) {
    _currentRawMemo = rawMemo;
  }

  void _updatePendingRawChanges() {
    if (_memos.isEmpty) {
      return;
    }

    final currentMemo = _memos[state.currentMemoIndex];
    _memos[state.currentMemoIndex] = Memo(
      question: state.isShowingQuestion ? _currentRawMemo : currentMemo.question,
      answer: !state.isShowingQuestion ? _currentRawMemo : currentMemo.answer,
    );
  }

  void addNewMemo() {
    _updatePendingRawChanges();

    const newMemo = Memo.empty();
    _memos.add(newMemo);

    _currentRawMemo = newMemo.question;
    state = state.copyWith(
      currentMemoIndex: _memos.length - 1,
      memosCount: _memos.length,
      currentRawMemo: _currentRawMemo,
      isShowingQuestion: true,
    );
  }

  void updateCurrentMemoIndex(int index) {
    _updatePendingRawChanges();

    final targetMemo = _memos[index];

    _currentRawMemo = state.isShowingQuestion ? targetMemo.question : targetMemo.answer;
    state = state.copyWith(
      currentMemoIndex: index,
      currentRawMemo: _currentRawMemo,
    );
  }

  void switchCurrentMemoContents() {
    print('UPDATING EDITOR:');
    print('* BEFORE SAVING TO STATE.CURRENT: ${_memos[state.currentMemoIndex]}:\n');
    _updatePendingRawChanges();
    print('* AFTER SAVING TO STATE.CURRENT: ${_memos[state.currentMemoIndex]}:\n');

    final currentMemo = _memos[state.currentMemoIndex];

    _currentRawMemo = state.isShowingQuestion ? currentMemo.answer : currentMemo.question;
    state = state.copyWith(
      isShowingQuestion: !state.isShowingQuestion,
      currentRawMemo: _currentRawMemo,
    );
    print('* AFTER STATE UPDATE TO STATE.CURRENT: ${_memos[state.currentMemoIndex]}:\n');
  }

  void clearCurrentMemoContents() {
    final currentMemo = _memos[state.currentMemoIndex];

    final isShowingQuestion = state.isShowingQuestion;
    final updatedCurrentMemo = Memo(
      question: isShowingQuestion ? [] : currentMemo.question,
      answer: !isShowingQuestion ? [] : currentMemo.answer,
    );
    _memos[state.currentMemoIndex] = updatedCurrentMemo;

    _currentRawMemo = <Map<String, dynamic>>[];
    state = state.copyWith(currentRawMemo: _currentRawMemo);
  }

  void deleteCurrentMemo() {
    final memosCount = _memos.length;
    if (memosCount == 1) {
      _currentRawMemo = <Map<String, dynamic>>[];
      _memos.clear();
      addNewMemo();
      return;
    }

    final currentIndex = state.currentMemoIndex;
    _memos.removeAt(currentIndex);

    final newCount = _memos.length;
    final newIndex = currentIndex >= newCount ? newCount - 1 : currentIndex;
    final memoAtIndex = _memos[newIndex];

    _currentRawMemo = memoAtIndex.question;
    state = state.copyWith(
      currentMemoIndex: newIndex,
      memosCount: newCount,
      currentRawMemo: _currentRawMemo,
      isShowingQuestion: true,
    );
  }

  //
  // Collection Actions
  //

  void clearCollection() {
    _currentRawMemo = <Map<String, dynamic>>[];
    _memos.clear();
    addNewMemo();
  }

  Future<void> exportCollection({bool keepingChanges = true}) async {
    _updatePendingRawChanges();

    final tempCollection = Collection(
      name: 'my_temp_collection',
      description: 'My temp description of this collection',
      category: 'TempCategory',
      tags: const ['temp tag 1', 'temp tag 2'],
      memos: _memos,
    );

    await services.saveCollection(tempCollection);
    if (!keepingChanges) {
      clearCollection();
    }
  }

  Future<void> importCollection() async {
    final importedCollection = await services.importCollection();

    _memos
      ..clear()
      ..addAll(importedCollection.memos);

    _currentRawMemo = _memos.first.question;
    state = state.copyWith(
      currentMemoIndex: 0,
      currentRawMemo: _currentRawMemo,
      memosCount: _memos.length,
      isShowingQuestion: true,
    );
  }
}

class EditorControllerState with EquatableMixin {
  EditorControllerState({
    required this.currentMemoIndex,
    required this.currentRawMemo,
    required this.memosCount,
    required this.isShowingQuestion,
  });
  final int currentMemoIndex;
  final List<Map<String, dynamic>> currentRawMemo;

  final int memosCount;
  final bool isShowingQuestion;

  EditorControllerState copyWith({
    int? currentMemoIndex,
    List<Map<String, dynamic>>? currentRawMemo,
    int? memosCount,
    bool? isShowingQuestion,
  }) =>
      EditorControllerState(
        currentMemoIndex: currentMemoIndex ?? this.currentMemoIndex,
        currentRawMemo: currentRawMemo ?? this.currentRawMemo,
        memosCount: memosCount ?? this.memosCount,
        isShowingQuestion: isShowingQuestion ?? this.isShowingQuestion,
      );

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [currentMemoIndex, currentRawMemo, memosCount, isShowingQuestion];
}
