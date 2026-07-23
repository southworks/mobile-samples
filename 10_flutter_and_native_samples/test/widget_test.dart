import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_and_native_samples/models/biometric_type.dart';

void main() {
  // No biometric/platform unit tests: system prompts need a real device.
  // This smoke check keeps `flutter test` green for the sample package.
  test('BiometricType.fromWire accepts the shared contract values', () {
    expect(BiometricType.fromWire('fingerprint'), BiometricType.fingerprint);
    expect(BiometricType.fromWire('face'), BiometricType.face);
  });
}
