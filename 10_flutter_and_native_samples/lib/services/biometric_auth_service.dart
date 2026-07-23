import 'package:flutter/services.dart';

import '../models/biometric_auth_result.dart';
import '../models/biometric_status.dart';

/// Dart façade over the shared MethodChannel.
///
/// Flutter sends the authentication request, but does not access biometric APIs.
final class BiometricAuthService {
  BiometricAuthService({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('examples.native_biometric_auth/biometrics');

  final MethodChannel _channel;

  Future<BiometricStatus> getStatus() async {
    final response = await _channel.invokeMethod<Object?>('getBiometricStatus');
    return BiometricStatus.fromMap(_asStringKeyedMap(response));
  }

  Future<BiometricAuthResult> authenticate({required String reason}) async {
    final response = await _channel.invokeMethod<Object?>(
      'authenticate',
      <String, Object?>{'reason': reason},
    );
    return BiometricAuthResult.fromMap(_asStringKeyedMap(response));
  }

  Map<Object?, Object?> _asStringKeyedMap(Object? response) {
    if (response is! Map) {
      throw FormatException(
        'Expected a Map from the MethodChannel, got ${response.runtimeType}.',
      );
    }
    return Map<Object?, Object?>.from(response);
  }
}
