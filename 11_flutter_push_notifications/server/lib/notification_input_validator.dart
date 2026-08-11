class InputValidationException implements Exception {
  InputValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NotificationInputValidator {
  static const maxTitleLength = 30;
  static const maxBodyLength = 100;

  void validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw InputValidationException('Title cannot be empty.');
    }
    if (trimmed.length > maxTitleLength) {
      throw InputValidationException(
        'Title must be at most $maxTitleLength characters.',
      );
    }
  }

  void validateBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw InputValidationException('Body cannot be empty.');
    }
    if (trimmed.length > maxBodyLength) {
      throw InputValidationException(
        'Body must be at most $maxBodyLength characters.',
      );
    }
  }
}
