/// Result of an asynchronous computation executed by native code.
final class NativeComputationResult {
  const NativeComputationResult({
    required this.result,
    required this.durationMs,
  });

  final String result;
  final int durationMs;

  factory NativeComputationResult.fromMap(Map<Object?, Object?> map) {
    final result = map['result'];
    final durationMs = map['durationMs'];

    if (result is! String) {
      throw const FormatException(
        'NativeComputationResult.result must be a String.',
      );
    }
    if (durationMs is! int) {
      throw const FormatException(
        'NativeComputationResult.durationMs must be an int.',
      );
    }

    return NativeComputationResult(result: result, durationMs: durationMs);
  }
}
