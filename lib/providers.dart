import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_editor/gateways/file_selector.dart';
import 'package:memo_editor/services/collection_services.dart';

final fileSelector = Provider((_) => FileSelectorImpl());

final collectionServices = Provider((ref) => CollectionServicesImpl(ref.read(fileSelector)));
