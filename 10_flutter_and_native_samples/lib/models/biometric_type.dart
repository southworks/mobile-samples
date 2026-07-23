/// Biometric modality reported by the native platform.
enum BiometricType {
  fingerprint,
  face,
  iris,
  multiple,
  none,
  unknown;

  static BiometricType fromWire(String? value) {
    return switch (value) {
      'fingerprint' => BiometricType.fingerprint,
      'face' => BiometricType.face,
      'iris' => BiometricType.iris,
      'multiple' => BiometricType.multiple,
      'none' => BiometricType.none,
      'unknown' => BiometricType.unknown,
      _ => throw FormatException(
        'Unexpected biometric type from native code: $value',
      ),
    };
  }

  String get label => switch (this) {
    BiometricType.fingerprint => 'Fingerprint',
    BiometricType.face => 'Face',
    BiometricType.iris => 'Iris',
    BiometricType.multiple => 'Multiple',
    BiometricType.none => 'None',
    BiometricType.unknown => 'Unknown',
  };
}
