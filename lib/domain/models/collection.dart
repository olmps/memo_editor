import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Defines all metadata of a collection (group) of `Memo`s
///
/// A [Collection] is just a domain-specific name for what we consider here a "Deck", if comparing the `Memo`
/// application to any other flashcard implementation. This "Deck" also holds required metadata that is used in the
/// `Memo` application.
@immutable
class Collection extends Equatable {
  const Collection({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
  });

  const Collection.empty({required this.id})
      : name = '',
        description = '',
        category = '',
        tags = const [];

  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;

  Collection copyWith({String? name, String? description, String? category, List<String>? tags}) => Collection(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [id, name, description, category, tags];
}
