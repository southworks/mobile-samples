import EventKit
import SwiftUI
import UIKit

extension EKCalendar {
    var typeDisplayName: String {
        switch type {
        case .local: "Local"
        case .calDAV: "CalDAV"
        case .exchange: "Exchange"
        case .subscription: "Suscripción"
        case .birthday: "Cumpleaños"
        @unknown default: "Otro"
        }
    }

    var swiftUIColor: Color {
        Color(uiColor: cgColor.map(UIColor.init(cgColor:)) ?? .systemBlue)
    }
}
