import Foundation

enum CalendarSampleError: LocalizedError, Equatable {
    case emptyTitle
    case invalidDateRange
    case missingReadPermission(CalendarAuthorizationState)
    case missingWritePermission(CalendarAuthorizationState)
    case missingDefaultCalendar
    case missingEditableEvent
    case eventKitFailure(String)

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            "Ingresá un título antes de guardar."
        case .invalidDateRange:
            "La fecha de fin debe ser posterior a la fecha de inicio."
        case .missingReadPermission(let state):
            "No hay permiso suficiente para leer eventos. Estado actual: \(state.title)."
        case .missingWritePermission(let state):
            "No hay permiso suficiente para escribir eventos. Estado actual: \(state.title)."
        case .missingDefaultCalendar:
            "No hay un calendario por defecto disponible para crear eventos."
        case .missingEditableEvent:
            "No se encontró un evento próximo para abrir en modo edición."
        case .eventKitFailure(let message):
            message
        }
    }
}
