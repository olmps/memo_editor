import 'package:memo_editor/core/faults/exceptions/base_exception.dart';

/// Exception that should be thrown when a runtime-expected validation failed
class ValidationException extends BaseException {
  /// Thrown when trying to parse a collection of unexpected format
  ValidationException.malformedCollection({required String debugInfo})
      : super(type: ExceptionType.malformedCollection, debugInfo: debugInfo);
}
