import 'biometric_type.dart';

/// Availability snapshot returned by `getBiometricStatus`.
final class BiometricStatus {
  const BiometricStatus({
    required this.available,
    required this.type,
    this.reason,
  });

  final bool available;
  final BiometricType type;
  final String? reason;

  factory BiometricStatus.fromMap(Map<Object?, Object?> map) {
    final available = map['available'];
    final type = map['type'];
    final reason = map['reason'];

    if (available is! bool) {
      throw const FormatException('BiometricStatus.available must be a bool.');
    }
    if (type is! String) {
      throw const FormatException('BiometricStatus.type must be a String.');
    }
    if (reason != null && reason is! String) {
      throw const FormatException(
        'BiometricStatus.reason must be a String or null.',
      );
    }

    final status = BiometricStatus(
      available: available,
      type: BiometricType.fromWire(type),
      reason: reason as String?,
    );

    if (status.available && status.reason != null) {
      throw const FormatException(
        'BiometricStatus.reason must be null when available is true.',
      );
    }
    if (!status.available &&
        (status.reason == null || status.reason!.isEmpty)) {
      throw const FormatException(
        'BiometricStatus.reason is required when available is false.',
      );
    }

    return status;
  }
}
