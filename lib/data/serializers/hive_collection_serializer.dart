import 'package:memo_editor/data/gateways/hive/hive_models.dart';
import 'package:memo_editor/data/serializers/serializer.dart';
import 'package:memo_editor/domain/models/collection.dart';

class HiveCollectionSerializer implements Serializer<Collection, HiveCollection> {
  @override
  Collection from(HiveCollection hive) =>
      Collection(id: hive.id, name: hive.name, description: hive.description, category: hive.category, tags: hive.tags);

  @override
  HiveCollection to(Collection collection) => HiveCollection(
        id: collection.id,
        name: collection.name,
        description: collection.description,
        category: collection.category,
        tags: collection.tags,
      );
}
