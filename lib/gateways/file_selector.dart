import 'dart:typed_data';

import 'package:file_selector/file_selector.dart' as fs;

abstract class FileSelector {
  Future<String?> getSavePathWithSelector({String? suggestedName, String? confirmButtonText});
  Future<Uint8List?> loadSingleFileWithSelector(
      {List<String>? mimeTypes, String? suggestedName, String? confirmButtonText});
  Future<void> writeFile(Uint8List bytes, {required String path, String? mimeType});
  Future<Uint8List> readFile(String path);
}

class FileSelectorImpl extends FileSelector {
  @override
  Future<String?> getSavePathWithSelector({String? suggestedName, String? confirmButtonText}) =>
      fs.getSavePath(suggestedName: suggestedName, confirmButtonText: confirmButtonText);

  @override
  Future<Uint8List?> loadSingleFileWithSelector({
    List<String>? mimeTypes,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    final xTypeGroups = [fs.XTypeGroup(mimeTypes: mimeTypes)];
    final file = await fs.openFile(acceptedTypeGroups: xTypeGroups, confirmButtonText: confirmButtonText);

    if (file == null) {
      return null;
    }

    return file.readAsBytes();
  }

  @override
  Future<void> writeFile(Uint8List bytes, {required String path, String? mimeType}) {
    final file = fs.XFile.fromData(bytes, mimeType: mimeType);

    return file.saveTo(path);
  }

  @override
  Future<Uint8List> readFile(String path) {
    final file = fs.XFile(path);
    return file.readAsBytes();
  }
}
