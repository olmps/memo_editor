import 'package:meta/meta.dart';

/// Defines all metadata of a collection (group) of `Memo`s
///
/// A [Collection] is just a domain-specific name for what we consider here a "Deck", if comparing the `Memo`
/// application to any other flashcard implementation. This "Deck" also holds required metadata that is used in the
/// `Memo` application.
@immutable
class Collection {
  const Collection({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
}
