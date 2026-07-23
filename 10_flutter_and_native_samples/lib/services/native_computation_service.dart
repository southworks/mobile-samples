import 'package:flutter/services.dart';

import '../models/native_computation_result.dart';

/// Dart façade over the async-computation MethodChannel.
/// Flutter only sends the request; the work runs on a native background thread.
final class NativeComputationService {
  NativeComputationService({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('examples.flutter_native_calls/async_task');

  final MethodChannel _channel;

  Future<NativeComputationResult> runDelayedTask() async {
    final response = await _channel.invokeMethod<Object?>('runDelayedTask');

    if (response is! Map) {
      throw FormatException(
        'Expected a Map from the MethodChannel, got ${response.runtimeType}.',
      );
    }
    return NativeComputationResult.fromMap(
      Map<Object?, Object?>.from(response),
    );
  }
}
