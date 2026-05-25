import SwiftUI

enum AppEventColor: String, CaseIterable, Identifiable {
    case sky
    case mint
    case coral
    case amber
    case indigo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sky: "Sky"
        case .mint: "Mint"
        case .coral: "Coral"
        case .amber: "Amber"
        case .indigo: "Indigo"
        }
    }

    var color: Color {
        switch self {
        case .sky: .blue
        case .mint: .mint
        case .coral: .pink
        case .amber: .orange
        case .indigo: .indigo
        }
    }
}
