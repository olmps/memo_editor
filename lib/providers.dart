import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo_editor/data/gateways/file_selector.dart';
import 'package:memo_editor/data/gateways/hive/hive_database.dart';
import 'package:memo_editor/data/repositories/collection_repository.dart';
import 'package:memo_editor/data/repositories/memo_repository.dart';
import 'package:memo_editor/data/repositories/transfer_repository.dart';
import 'package:memo_editor/domain/services/collection_services.dart';
import 'package:memo_editor/domain/services/memo_services.dart';

class AppState {
  const AppState(this.collectionServices, this.memoServices);

  final CollectionServices collectionServices;
  final MemoServices memoServices;
}

Future<AppState> init() async {
  // Gateways
  await openDatabase();
  final hive = HiveDatabaseImpl();
  final fileSelector = FileSelectorImpl();

  // Repositories
  final memoRepo = MemoRepositoryImpl(hive);
  final collectionRepo = CollectionRepositoryImpl(hive);
  final transferRepo = TransferRepositoryImpl(fileSelector);

  // Services
  final collectionServices = CollectionServicesImpl(collectionRepo, memoRepo, transferRepo);
  final memoServices = MemoServicesImpl(memoRepo);

  return AppState(collectionServices, memoServices);
}

final collectionServices = Provider<CollectionServices>((ref) => throw InconsistentStateError(
    'Trying to access a collectionServices provider before overridding in the main ProviderScope'));
final memoServices = Provider<MemoServices>((ref) => throw InconsistentStateError(
    'Trying to access a memoServices provider before overridding in the main ProviderScope'));
