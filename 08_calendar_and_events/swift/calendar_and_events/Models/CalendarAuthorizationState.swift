import EventKit

enum CalendarAuthorizationState: String, CaseIterable, Identifiable {
    case notDetermined
    case fullAccess
    case writeOnly
    case denied
    case restricted
    case unknown

    var id: String { rawValue }

    init(status: EKAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .fullAccess:
            self = .fullAccess
        case .writeOnly:
            self = .writeOnly
        case .authorized:
            self = .fullAccess
        @unknown default:
            self = .unknown
        }
    }

    var title: String {
        switch self {
        case .notDetermined: "No determinado"
        case .fullAccess: "Acceso completo"
        case .writeOnly: "Solo escritura"
        case .denied: "Denegado"
        case .restricted: "Restringido"
        case .unknown: "Desconocido"
        }
    }

    var message: String {
        switch self {
        case .notDetermined:
            "La app todavía no pidió permiso para acceder al calendario del sistema."
        case .fullAccess:
            "La app puede leer y escribir eventos reales del usuario."
        case .writeOnly:
            "La app puede crear o modificar eventos, pero no leer los existentes."
        case .denied:
            "El usuario rechazó el permiso. Hay que habilitarlo desde Settings."
        case .restricted:
            "El dispositivo o controles parentales restringen el acceso."
        case .unknown:
            "El sistema devolvió un estado no reconocido."
        }
    }

    var canReadEvents: Bool { self == .fullAccess }

    var canWriteEvents: Bool {
        self == .fullAccess || self == .writeOnly
    }
}
