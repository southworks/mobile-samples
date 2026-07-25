/// One event pushed by the native EventChannel ticker.
final class NativeTickEvent {
  const NativeTickEvent({
    required this.tick,
    required this.timestampMs,
  });

  final int tick;
  final int timestampMs;

  factory NativeTickEvent.fromMap(Map<Object?, Object?> map) {
    final tick = map['tick'];
    final timestampMs = map['timestampMs'];

    if (tick is! int) {
      throw const FormatException('NativeTickEvent.tick must be an int.');
    }
    if (timestampMs is! int) {
      throw const FormatException(
        'NativeTickEvent.timestampMs must be an int.',
      );
    }

    return NativeTickEvent(tick: tick, timestampMs: timestampMs);
  }
}
