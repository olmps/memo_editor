import 'package:hive/hive.dart';

part 'hive_models.g.dart';

@HiveType(typeId: 0)
class HiveCollection {
  HiveCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final List<String> tags;
}

@HiveType(typeId: 1)
class HiveMemo {
  HiveMemo({required this.uniqueId, required this.question, required this.answer, required this.collectionId});

  @HiveField(0)
  final String uniqueId;

  @HiveField(1)
  final List<Map<String, dynamic>> question;

  @HiveField(2)
  final List<Map<String, dynamic>> answer;

  @HiveField(3)
  final String collectionId;
}
