import Flutter
import Foundation

/// Runs a delayed native task on a background queue and returns the
/// result to Flutter asynchronously on the main thread.
final class NativeComputationChannel {
  static let channelName = "examples.flutter_native_calls/async_task"

  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
  }

  func register() {
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call: call, result: result)
    }
  }

  func unregister() {
    channel.setMethodCallHandler(nil)
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "runDelayedTask":
      runDelayedTask(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func runDelayedTask(result: @escaping FlutterResult) {
    // Native work: sleep a random number of seconds, then reply on the main thread.
    DispatchQueue.global(qos: .userInitiated).async {
      let delaySeconds = Int.random(in: 1...10)
      let start = DispatchTime.now()
      Thread.sleep(forTimeInterval: TimeInterval(delaySeconds))
      let durationMs = Int(
        (DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
      )

      DispatchQueue.main.async {
        result([
          "result": "Native delay completed after \(delaySeconds) s",
          "durationMs": durationMs,
        ])
      }
    }
  }
}
