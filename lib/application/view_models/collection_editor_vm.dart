import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo_editor/domain/models/memo.dart';
import 'package:memo_editor/domain/services/memo_services.dart';

abstract class CollectionEditorVM extends StateNotifier<CollectionEditorState> {
  CollectionEditorVM(CollectionEditorState state, {required this.collectionId}) : super(state);

  /// Associated collection id with all of this memos
  final String collectionId;

  /// The current raw-representation of the selected memo's question or answer
  ///
  /// This property must always be kept in sync with any layout changes, because when the state changes, it must have
  /// the latest data to store it accurately.
  List<Map<String, dynamic>> get currentRawMemo;
  set currentRawMemo(List<Map<String, dynamic>> rawMemo);

  /// Deletes all memos
  ///
  /// Because a collection must always have at least one memo, it creates a blank new - and empty - one.
  Future<void> clearAllMemos();

  /// Deletes the current selected memo
  Future<void> deleteCurrentMemo();

  /// Clears all contents from the - currently selected - memo question or answer
  Future<void> clearCurrentMemoContents();

  /// Switches (or swap) the - currently selected - memo's answer/question
  ///
  /// If the question is displaying, swap to the answer, and vice-versa.
  Future<void> switchCurrentMemoContents();

  /// Updates the selected memo to the one in available in [index]
  Future<void> updateCurrentMemoIndex(int index);

  /// Creates a new blank memo and selects it as the current one
  Future<void> addNewMemo();
}

class CollectionEditorVMImpl extends CollectionEditorVM {
  CollectionEditorVMImpl(this._memoServices, {required String collectionId})
      : super(LoadingCollectionEditorState(), collectionId: collectionId) {
    _loadMemos();
  }

  final MemoServices _memoServices;

  /// Late-initialized list of memos associated with this [collectionId]
  late final List<Memo> _memos;

  List<Map<String, dynamic>> _currentRawMemo = [];

  @override
  List<Map<String, dynamic>> get currentRawMemo => _loadedState.currentRawMemo;

  @override
  set currentRawMemo(List<Map<String, dynamic>> rawMemo) {
    _currentRawMemo = rawMemo;
  }

  /// Returns the current [state] type-casted (forced) to a [LoadedCollectionEditorState]
  LoadedCollectionEditorState get _loadedState => state as LoadedCollectionEditorState;

  @override
  Future<void> addNewMemo() async {
    if (!_assertAndUpdatePendingChanges()) {
      return;
    }

    state = _loadedState.copyWith(isUpdating: true);
    final newMemo = await _memoServices.putPristineMemo(collectionId: collectionId);
    _memos.add(newMemo);
    _currentRawMemo = newMemo.question;

    state = _loadedState.copyWith(
      currentMemoIndex: _memos.length - 1,
      memosCount: _memos.length,
      currentRawMemo: _currentRawMemo,
      isShowingQuestion: true,
      isUpdating: false,
    );
  }

  @override
  Future<void> updateCurrentMemoIndex(int index) async {
    if (!_assertAndUpdatePendingChanges()) {
      return;
    }

    state = _loadedState.copyWith(isUpdating: true);
    final currentMemo = _memos[_loadedState.currentMemoIndex];
    await _memoServices.putMemo(currentMemo, collectionId: collectionId);

    final targetMemo = _memos[index];
    _currentRawMemo = _loadedState.isShowingQuestion ? targetMemo.question : targetMemo.answer;
    state = _loadedState.copyWith(
      currentMemoIndex: index,
      currentRawMemo: _currentRawMemo,
      isUpdating: false,
    );
  }

  @override
  Future<void> switchCurrentMemoContents() async {
    if (!_assertAndUpdatePendingChanges()) {
      return;
    }

    state = _loadedState.copyWith(isUpdating: true);
    final currentMemo = _memos[_loadedState.currentMemoIndex];
    await _memoServices.putMemo(currentMemo, collectionId: collectionId);

    // Swaps the content according to what is being currently shown
    _currentRawMemo = _loadedState.isShowingQuestion ? currentMemo.answer : currentMemo.question;
    state = _loadedState.copyWith(
      isShowingQuestion: !_loadedState.isShowingQuestion,
      currentRawMemo: _currentRawMemo,
      isUpdating: false,
    );
  }

  @override
  Future<void> clearCurrentMemoContents() async {
    if (!_assertAndUpdatePendingChanges()) {
      return;
    }

    state = _loadedState.copyWith(isUpdating: true);

    final currentMemo = _memos[_loadedState.currentMemoIndex];
    final isShowingQuestion = _loadedState.isShowingQuestion;
    // Updates the respective content if showing a question or answer
    final updatedCurrentMemo = currentMemo.copyWith(
      question: isShowingQuestion ? [] : currentMemo.question,
      answer: !isShowingQuestion ? [] : currentMemo.answer,
    );

    await _memoServices.putMemo(updatedCurrentMemo, collectionId: collectionId);

    _memos[_loadedState.currentMemoIndex] = updatedCurrentMemo;
    // Also set the current state to reflect this clear operation
    _currentRawMemo = [];
    state = _loadedState.copyWith(currentRawMemo: _currentRawMemo, isUpdating: false);
  }

  @override
  Future<void> deleteCurrentMemo() async {
    final memosCount = _memos.length;
    // We don't allow collections having less than a single memo
    if (!_assertAndUpdatePendingChanges() || memosCount == 1) {
      return;
    }

    state = _loadedState.copyWith(isUpdating: true);

    final currentIndex = _loadedState.currentMemoIndex;
    await _memoServices.deleteMemoById(_memos[currentIndex].uniqueId);
    _memos.removeAt(currentIndex);

    final newCount = _memos.length;
    // Normalize the next index based on the current position + total updated amount of memos
    final newIndex = currentIndex >= newCount ? newCount - 1 : currentIndex;
    final memoAtIndex = _memos[newIndex];

    _currentRawMemo = memoAtIndex.question;
    state = _loadedState.copyWith(
      currentMemoIndex: newIndex,
      memosCount: newCount,
      currentRawMemo: _currentRawMemo,
      isShowingQuestion: true,
      isUpdating: false,
    );
  }

  @override
  Future<void> clearAllMemos() async {
    if (!_assertAndUpdatePendingChanges()) {
      return;
    }

    state = _loadedState.copyWith(isUpdating: true);

    await _memoServices.deleteAllMemos(collectionId: collectionId);
    _memos.clear();

    // Add a new blank memo because we don't allow collections without memos
    final newMemo = await _memoServices.putPristineMemo(collectionId: collectionId);
    _memos.add(newMemo);
    _currentRawMemo = newMemo.question;

    state = _loadedState.copyWith(
      currentMemoIndex: 0,
      memosCount: 1,
      currentRawMemo: _currentRawMemo,
      isShowingQuestion: true,
      isUpdating: false,
    );
  }

  Future<void> _loadMemos() async {
    _memos = await _memoServices.getAllMemos(collectionId: collectionId);
    const initialIndex = 0;

    state = LoadedCollectionEditorState(
      currentMemoIndex: initialIndex,
      currentRawMemo: _memos[initialIndex].question,
      memosCount: _memos.length,
      isShowingQuestion: true,
      isUpdating: false,
    );
  }

  /// Asserts for this view model's internal consistency before making any asynchronous changes
  ///
  /// The assertion simply checks that the **current loaded state** is not updating anything else, returning `false` if
  /// it's in fact the middle of some update. If there are no pending updates, syncs the [_currentRawMemo] with its
  /// respective current memo's question or answer.
  ///
  /// Ideally this should be called before making any impactful operation within this view model.
  ///
  /// This must only be called when we are sure that the current state is [LoadedCollectionEditorState], throws a
  /// [InconsistentStateError.viewModel] otherwise.
  bool _assertAndUpdatePendingChanges() {
    if (state is! LoadedCollectionEditorState) {
      throw InconsistentStateError.viewModel(
          'Trying to run a critical operation before having the collection editor state loaded');
    }

    // If it's updating, we just return false because we don't want to deal with multiple async operations, as we may
    // eventually face internal state inconsistency, due to race conditions
    if (_loadedState.isUpdating) {
      return false;
    }

    final currentMemo = _memos[_loadedState.currentMemoIndex];

    _memos[_loadedState.currentMemoIndex] = currentMemo.copyWith(
      question: _loadedState.isShowingQuestion ? _currentRawMemo : currentMemo.question,
      answer: !_loadedState.isShowingQuestion ? _currentRawMemo : currentMemo.answer,
    );

    return true;
  }
}

abstract class CollectionEditorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingCollectionEditorState extends CollectionEditorState {}

class LoadedCollectionEditorState extends CollectionEditorState {
  LoadedCollectionEditorState({
    required this.currentMemoIndex,
    required this.currentRawMemo,
    required this.memosCount,
    required this.isShowingQuestion,
    required this.isUpdating,
  });

  final int currentMemoIndex;
  final List<Map<String, dynamic>> currentRawMemo;

  final int memosCount;
  final bool isShowingQuestion;
  final bool isUpdating;

  LoadedCollectionEditorState copyWith({
    int? currentMemoIndex,
    List<Map<String, dynamic>>? currentRawMemo,
    int? memosCount,
    bool? isShowingQuestion,
    bool? isUpdating,
  }) =>
      LoadedCollectionEditorState(
        currentMemoIndex: currentMemoIndex ?? this.currentMemoIndex,
        currentRawMemo: currentRawMemo ?? this.currentRawMemo,
        memosCount: memosCount ?? this.memosCount,
        isShowingQuestion: isShowingQuestion ?? this.isShowingQuestion,
        isUpdating: isUpdating ?? this.isUpdating,
      );

  @override
  List<Object?> get props => [currentMemoIndex, currentRawMemo, memosCount, isShowingQuestion, isUpdating];
}
