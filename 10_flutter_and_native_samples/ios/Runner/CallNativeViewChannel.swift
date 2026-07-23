import Flutter
import UIKit

/// MethodChannel bridge that presents [ProfileViewController].
///
/// Flutter requests navigation; iOS owns the full-screen native UI.
final class CallNativeViewChannel {
  static let channelName = "examples.flutter_native_calls/call_native_view"

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
    case "openProfile":
      openProfile(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func openProfile(result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      guard let presenter = Self.topViewController() else {
        result(
          FlutterError(
            code: "unavailable",
            message: "Unable to find a view controller to present the native profile.",
            details: nil
          )
        )
        return
      }

      let profile = ProfileViewController()
      profile.modalPresentationStyle = .pageSheet
      presenter.present(profile, animated: true) {
        result(nil)
      }
    }
  }

  private static func topViewController(
    base: UIViewController? = {
      let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      let window = scenes
        .flatMap(\.windows)
        .first(where: \.isKeyWindow)
      return window?.rootViewController
    }()
  ) -> UIViewController? {
    if let navigation = base as? UINavigationController {
      return topViewController(base: navigation.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      return topViewController(base: tab.selectedViewController)
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}
