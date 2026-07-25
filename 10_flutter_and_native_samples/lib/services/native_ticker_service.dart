import 'package:flutter/services.dart';

import '../models/native_tick_event.dart';

/// Dart façade over the native ticker EventChannel.
///
/// Native owns the timer and pushes events; Flutter only listens and cancels.
final class NativeTickerService {
  NativeTickerService({EventChannel? channel})
    : _channel =
          channel ??
          const EventChannel('examples.flutter_native_calls/ticker');

  final EventChannel _channel;

  /// Starts receiving ticks when subscribed; stops when the subscription is
  /// cancelled (native `onCancel`).
  Stream<NativeTickEvent> ticks() {
    return _channel.receiveBroadcastStream().map((event) {
      if (event is! Map) {
        throw FormatException(
          'Expected a Map from the EventChannel, got ${event.runtimeType}.',
        );
      }
      return NativeTickEvent.fromMap(Map<Object?, Object?>.from(event));
    });
  }
}
