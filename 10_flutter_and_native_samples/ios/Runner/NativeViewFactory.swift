import Flutter
import UIKit

/// Creates the native iOS view requested by Flutter's UiKitView widget.
final class NativeViewFactory: NSObject, FlutterPlatformViewFactory {
  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeLabelView(frame: frame)
  }
}
