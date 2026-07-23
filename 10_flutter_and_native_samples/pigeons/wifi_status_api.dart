import 'package:pigeon/pigeon.dart';

// Pigeon schema. Running codegen produces type-safe Dart, Kotlin and Swift.
// Edit this file and re-run:
//   dart run pigeon --input pigeons/wifi_status_api.dart
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/pigeon/wifi_status.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/example/flutter_and_native_samples/WifiStatusApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.example.flutter_and_native_samples',
    ),
    swiftOut: 'ios/Runner/WifiStatusApi.g.swift',
    dartPackageName: 'flutter_and_native_samples',
  ),
)

enum WifiConnectionType { wifi, other, none, unknown }

class WifiStatus {
  WifiStatus({
    required this.isEnabled,
    required this.isConnected,
    required this.connectionType,
    this.ssid,
    this.signalLevel,
  });

  /// Whether the Wi-Fi radio is turned on (best effort; iOS cannot report it).
  bool isEnabled;

  /// Whether the active network connection is going through Wi-Fi.
  bool isConnected;

  /// Type of the active network connection.
  WifiConnectionType connectionType;

  /// Network name. Usually null without extra permissions/entitlements.
  String? ssid;

  /// Signal strength bucket (0-4). Null when unavailable.
  int? signalLevel;
}

@HostApi()
abstract class WifiStatusApi {
  @async
  WifiStatus getWifiStatus();
}
