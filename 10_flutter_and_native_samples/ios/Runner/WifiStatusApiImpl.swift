import Foundation
import Network

/// Implements the Pigeon-generated `WifiStatusApi` using the Network framework.
///
/// The WifiStatus type is defined once in the Pigeon schema; this only fills it in.
final class WifiStatusApiImpl: WifiStatusApi {
  private let monitorQueue = DispatchQueue(label: "examples.wifi_status.monitor")

  func getWifiStatus(completion: @escaping (Result<WifiStatus, Error>) -> Void) {
    let monitor = NWPathMonitor()

    monitor.pathUpdateHandler = { path in
      let usesWifi = path.usesInterfaceType(.wifi)
      let satisfied = path.status == .satisfied

      let connectionType: WifiConnectionType
      if usesWifi {
        connectionType = .wifi
      } else if satisfied {
        connectionType = .other
      } else {
        connectionType = WifiConnectionType.none
      }

      // iOS has no public API for the radio toggle, so isEnabled is best effort.
      let status = WifiStatus(
        isEnabled: usesWifi,
        isConnected: usesWifi && satisfied,
        connectionType: connectionType,
        ssid: nil,
        signalLevel: nil
      )

      monitor.cancel()
      DispatchQueue.main.async {
        completion(.success(status))
      }
    }

    monitor.start(queue: monitorQueue)
  }
}
