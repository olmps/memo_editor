import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Defines a unit of a `Collection`
///
/// A [Memo] is just a domain-specific name for what we consider here a "Card", if comparing the `Memo` application to
/// any other flashcard implementation.
@immutable
class Memo extends Equatable {
  const Memo({required this.question, required this.answer});
  const Memo.empty()
      : question = const <Map<String, dynamic>>[],
        answer = const <Map<String, dynamic>>[];

  final List<Map<String, dynamic>> question;
  final List<Map<String, dynamic>> answer;

  @override
  bool? get stringify => true;
  @override
  List<Object?> get props => [question, answer];
}
