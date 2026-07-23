import Flutter
import LocalAuthentication
import UIKit

/// Bridges Flutter MethodChannel calls to LocalAuthentication.
///
/// iOS evaluates biometrics and returns only the authentication result.
final class BiometricAuthChannel {
  static let channelName = "examples.native_biometric_auth/biometrics"

  private let channel: FlutterMethodChannel
  private var authenticationInProgress = false

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
    authenticationInProgress = false
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getBiometricStatus":
      result(getBiometricStatus())
    case "authenticate":
      authenticate(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getBiometricStatus() -> [String: Any?] {
    let context = LAContext()
    var error: NSError?

    // Probe availability without presenting a system prompt.
    let canEvaluate = context.canEvaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      error: &error
    )

    if canEvaluate {
      return [
        "available": true,
        "type": biometricTypeName(for: context.biometryType),
        "reason": nil,
      ]
    }

    let reason = mapAvailabilityError(error)
    return [
      "available": false,
      "type": "none",
      "reason": reason,
    ]
  }

  private func authenticate(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if authenticationInProgress {
      result(
        authFailure(
          errorCode: "alreadyInProgress",
          errorMessage: "A biometric authentication request is already in progress."
        )
      )
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let reason = args["reason"] as? String,
      !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      result(
        authFailure(
          errorCode: "invalidArguments",
          errorMessage: "authenticate requires a non-empty reason string."
        )
      )
      return
    }

    let status = getBiometricStatus()
    let available = status["available"] as? Bool ?? false
    if !available {
      let unavailableReason = status["reason"] as? String ?? "unavailable"
      result(
        authFailure(
          errorCode: unavailableReason,
          errorMessage: "Biometric authentication is not available (\(unavailableReason))."
        )
      )
      return
    }

    authenticationInProgress = true

    // Create a fresh LAContext for each authentication attempt.
    let context = LAContext()
    context.localizedCancelTitle = "Cancel"

    // iOS evaluates biometrics and returns only the authentication result.
    context.evaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      localizedReason: reason
    ) { [weak self] success, error in
      DispatchQueue.main.async {
        guard let self else {
          return
        }

        self.authenticationInProgress = false

        if success {
          result([
            "success": true,
            "errorCode": NSNull(),
            "errorMessage": NSNull(),
          ])
          return
        }

        let mapped = self.mapAuthenticationError(error)
        result(mapped)
      }
    }
  }

  private func biometricTypeName(for type: LABiometryType) -> String {
    switch type {
    case .touchID:
      return "fingerprint"
    case .faceID:
      return "face"
    case .opticID:
      return "iris"
    case .none:
      return "none"
    @unknown default:
      return "unknown"
    }
  }

  private func mapAvailabilityError(_ error: NSError?) -> String {
    guard let error else {
      return "unknown"
    }

    switch error.code {
    case LAError.biometryNotAvailable.rawValue:
      return "notSupported"
    case LAError.biometryNotEnrolled.rawValue:
      return "notEnrolled"
    case LAError.biometryLockout.rawValue:
      return "temporarilyLocked"
    case LAError.passcodeNotSet.rawValue:
      return "notSupported"
    default:
      return "unavailable"
    }
  }

  private func mapAuthenticationError(_ error: Error?) -> [String: Any?] {
    guard let laError = error as? LAError else {
      return authFailure(
        errorCode: "unknown",
        errorMessage: error?.localizedDescription ?? "Biometric authentication failed."
      )
    }

    switch laError.code {
    case .userCancel:
      return authFailure(
        errorCode: "userCanceled",
        errorMessage: "Authentication was canceled by the user"
      )
    case .appCancel, .systemCancel:
      return authFailure(
        errorCode: "systemCanceled",
        errorMessage: "Authentication was canceled by the system"
      )
    case .authenticationFailed:
      return authFailure(
        errorCode: "authenticationFailed",
        errorMessage: "Biometric authentication failed."
      )
    case .biometryNotAvailable:
      return authFailure(
        errorCode: "notSupported",
        errorMessage: "Biometric authentication is not supported on this device."
      )
    case .biometryNotEnrolled:
      return authFailure(
        errorCode: "notEnrolled",
        errorMessage: "No biometrics are enrolled on this device."
      )
    case .biometryLockout:
      return authFailure(
        errorCode: "temporarilyLocked",
        errorMessage: "Biometric authentication is temporarily locked."
      )
    case .passcodeNotSet:
      return authFailure(
        errorCode: "notSupported",
        errorMessage: "Device passcode is not set; biometrics cannot be used."
      )
    case .userFallback:
      // Policy excludes device credentials; treat fallback as cancel.
      return authFailure(
        errorCode: "userCanceled",
        errorMessage: "Authentication was canceled by the user"
      )
    case .invalidContext, .notInteractive:
      return authFailure(
        errorCode: "unavailable",
        errorMessage: laError.localizedDescription
      )
    default:
      return authFailure(
        errorCode: "unknown",
        errorMessage: laError.localizedDescription
      )
    }
  }

  private func authFailure(errorCode: String, errorMessage: String) -> [String: Any?] {
    [
      "success": false,
      "errorCode": errorCode,
      "errorMessage": errorMessage,
    ]
  }
}
