import 'package:flutter/services.dart';

/// Opens a full native screen (Activity / UIViewController) via MethodChannel.
final class CallNativeViewService {
  CallNativeViewService({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('examples.flutter_native_calls/call_native_view');

  final MethodChannel _channel;

  /// Asks the host platform to present the native profile screen.
  Future<void> openProfile() async {
    await _channel.invokeMethod<void>('openProfile');
  }
}
