import 'dart:convert';
import 'dart:typed_data';

import 'package:memo_editor/core/faults/errors/serialization_error.dart';
import 'package:memo_editor/core/faults/exceptions/validation_exception.dart';
import 'package:memo_editor/data/gateways/file_selector.dart';
import 'package:memo_editor/data/serializers/json_collection_memos_serializer.dart';
import 'package:memo_editor/domain/transients/collection_memos.dart';

/// Handles all transfer-related operations for this application
///
/// A transfer operation probably means a read and/or write to the respective OS file system.
abstract class TransferRepository {
  /// Imports a single [CollectionMemos]
  ///
  /// {@template memo_editor.data.repositories.importCollectionMemos}
  /// The import uses the native OS "file picker or selector" to retrieve the raw representation of the selected file.
  /// After import, it tries to serialize this file to a [CollectionMemos] following a format that the memo application
  /// also knows how to handle.
  ///
  /// You can read about this format in this project's **README format example**.
  ///
  /// May return `null` if there were no picked files.
  ///
  /// Throws a [ValidationException.malformedCollection] if the picked file is malformed.
  /// {@endtemplate}
  Future<CollectionMemos?> importCollectionMemos();

  /// Exports a [collectionMemos] to a file
  ///
  /// {@template memo_editor.data.repositories.exportCollectionMemos}
  /// The export uses the native OS "file picker or selector" to select the desired folder to store this collection.
  /// After selecting the folder, it serializes the [CollectionMemos] to a raw format and saves to the destination.
  ///
  /// You can read about this format in this project's **README format example**.
  /// {@endtemplate}
  Future<void> exportCollectionMemos(CollectionMemos collectionMemos);
}

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this.fileSelector);

  final FileSelector fileSelector;

  static const _extension = '.json';
  static const _encoderIndent = '  '; // Two whitespaces
  final _serializer = JsonCollectionMemosSerializer();

  @override
  Future<void> exportCollectionMemos(CollectionMemos collectionMemos) async {
    final path = await fileSelector.getSavePathWithSelector(
      suggestedName: collectionMemos.collection.id + _extension,
      confirmButtonText: 'Salvar',
    );

    // This probably means that there was no selection, so we must simply ignore the next export steps
    if (path == null) {
      return;
    }

    final rawCollectionMemos = _serializer.to(collectionMemos);

    try {
      final encoder = JsonUtf8Encoder(_encoderIndent);
      final encodedCollection = encoder.convert(rawCollectionMemos);

      return fileSelector.writeFile(Uint8List.fromList(encodedCollection), path: path);
      // ignore: avoid_catching_errors
    } on JsonUnsupportedObjectError catch (error) {
      throw SerializationError(
        'Failed to export a `CollectionMemos` instance.\n'
        'Raw `CollectionMemos`: $rawCollectionMemos.\n'
        'Cause: ${error.toString()}',
      );
    }
  }

  @override
  Future<CollectionMemos?> importCollectionMemos() async {
    final fileBytes = await fileSelector.loadSingleFileWithSelector(extensions: [_extension]);

    // This probably means that there was no selection, so we must simply ignore the next import steps
    if (fileBytes == null) {
      return null;
    }

    try {
      final decodedRawCollection = utf8.decoder.convert(fileBytes);
      final dynamic rawCollection = jsonDecode(decodedRawCollection);

      if (rawCollection is Map<String, dynamic>) {
        return _serializer.from(rawCollection);
      } else {
        // Throw the same exception that the dart:convert throws, because we want to catch this exact same exception to
        // rethrow it as our own custom exception (the ValidationException)
        throw const FormatException('The imported file is not of type `Map<String, dynamic>`');
      }
    } on FormatException catch (exception) {
      throw ValidationException.malformedCollection(debugInfo: exception.toString());
      // ignore: avoid_catching_errors
    } on TypeError catch (error) {
      throw ValidationException.malformedCollection(debugInfo: error.toString());
    }
  }
}
