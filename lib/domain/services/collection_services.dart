import 'dart:convert';
import 'dart:typed_data';

import 'package:memo_editor/data/gateways/file_selector.dart';
import 'package:memo_editor/data/serializers/collection_json_serializer.dart';
import 'package:memo_editor/domain/models/collection.dart';

abstract class CollectionServices {
  Future<void> saveCollection(Collection collection);
  Future<Collection> importCollection();
}

class CollectionServicesImpl implements CollectionServices {
  CollectionServicesImpl(this.fileSelector);

  final FileSelector fileSelector;
  static const _extension = '.json';
  static const _encoderIndent = '  '; // Two whitespaces
  final _serializer = CollectionSerializer();

  @override
  Future<void> saveCollection(Collection collection) async {
    final path = await fileSelector.getSavePathWithSelector(
      suggestedName: collection.name + _extension,
      confirmButtonText: 'Salvar',
    );

    if (path == null) {
      // TODO(matuella): throw a human-readable error
      return;
    }

    final rawCollection = _serializer.to(collection);
    final encoder = JsonUtf8Encoder(_encoderIndent);
    final encodedCollection = encoder.convert(rawCollection);

    return fileSelector.writeFile(Uint8List.fromList(encodedCollection), path: path);
  }

  @override
  Future<Collection> importCollection() async {
    final fileBytes = await fileSelector.loadSingleFileWithSelector(
      confirmButtonText: 'Salvar',
    );

    if (fileBytes == null) {
      // TODO(matuella): throw a human-readable error
      throw 'Failed to read the imported file';
    }

    final decodedRawCollection = utf8.decoder.convert(fileBytes);
    final dynamic rawCollection = jsonDecode(decodedRawCollection);

    if (rawCollection is Map<String, dynamic>) {
      return _serializer.from(rawCollection);
    }

    // TODO(matuella): throw a human-readable error
    throw 'The imported file is not of type `Map<String, dynamic>`';
  }
}
