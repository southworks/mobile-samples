import Flutter
import Foundation

/// Pushes a tick event to Flutter every second while a listener is active.
///
/// Demonstrates EventChannel lifecycle: `onListen` starts the timer,
/// `onCancel` stops it.
final class NativeTickerChannel: NSObject, FlutterStreamHandler {
  static let channelName = "examples.flutter_native_calls/ticker"

  private let channel: FlutterEventChannel
  private var events: FlutterEventSink?
  private var timer: Timer?
  private var tick = 0

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterEventChannel(name: Self.channelName, binaryMessenger: messenger)
    super.init()
  }

  func register() {
    channel.setStreamHandler(self)
  }

  func unregister() {
    stopTicker()
    channel.setStreamHandler(nil)
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.events = events
    tick = 0
    // Emit the first tick immediately, then every second on the main run loop.
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.emitTick()
    }
    self.timer = timer
    emitTick()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopTicker()
    return nil
  }

  private func emitTick() {
    guard let events else {
      return
    }
    tick += 1
    let timestampMs = Int(Date().timeIntervalSince1970 * 1_000)
    events([
      "tick": tick,
      "timestampMs": timestampMs,
    ])
  }

  private func stopTicker() {
    timer?.invalidate()
    timer = nil
    events = nil
    tick = 0
  }
}
