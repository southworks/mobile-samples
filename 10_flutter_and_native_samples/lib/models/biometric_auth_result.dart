/// Outcome of a native `authenticate` call.
final class BiometricAuthResult {
  const BiometricAuthResult({
    required this.success,
    this.errorCode,
    this.errorMessage,
  });

  final bool success;
  final String? errorCode;
  final String? errorMessage;

  factory BiometricAuthResult.fromMap(Map<Object?, Object?> map) {
    final success = map['success'];
    final errorCode = map['errorCode'];
    final errorMessage = map['errorMessage'];

    if (success is! bool) {
      throw const FormatException(
        'BiometricAuthResult.success must be a bool.',
      );
    }
    if (errorCode != null && errorCode is! String) {
      throw const FormatException(
        'BiometricAuthResult.errorCode must be a String or null.',
      );
    }
    if (errorMessage != null && errorMessage is! String) {
      throw const FormatException(
        'BiometricAuthResult.errorMessage must be a String or null.',
      );
    }

    final result = BiometricAuthResult(
      success: success,
      errorCode: errorCode as String?,
      errorMessage: errorMessage as String?,
    );

    if (result.success &&
        (result.errorCode != null || result.errorMessage != null)) {
      throw const FormatException(
        'Successful biometric results must not include error fields.',
      );
    }
    if (!result.success &&
        (result.errorCode == null || result.errorCode!.isEmpty)) {
      throw const FormatException(
        'Failed biometric results must include an errorCode.',
      );
    }

    return result;
  }

  String get displayLabel {
    if (success) {
      return 'Success';
    }
    final code = errorCode ?? 'unknown';
    final message = errorMessage;
    if (message == null || message.isEmpty) {
      return code;
    }
    return '$code — $message';
  }
}
