import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var biometricAuthChannel: BiometricAuthChannel?
  private var nativeComputationChannel: NativeComputationChannel?
  private var callNativeViewChannel: CallNativeViewChannel?
  private var wifiStatusApi: WifiStatusApiImpl?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()

    let biometrics = BiometricAuthChannel(messenger: messenger)
    biometrics.register()
    biometricAuthChannel = biometrics

    let computation = NativeComputationChannel(messenger: messenger)
    computation.register()
    nativeComputationChannel = computation

    let callNativeView = CallNativeViewChannel(messenger: messenger)
    callNativeView.register()
    callNativeViewChannel = callNativeView

    // Pigeon-generated setup: the WifiStatus contract lives in the schema.
    let wifiStatus = WifiStatusApiImpl()
    WifiStatusApiSetup.setUp(binaryMessenger: messenger, api: wifiStatus)
    wifiStatusApi = wifiStatus

    // iOS draws this view; Flutter only hosts it through a PlatformView.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeViewPlugin") {
      registrar.register(
        NativeViewFactory(),
        withId: "examples.flutter_native_calls/native_view"
      )
    }
  }
}
