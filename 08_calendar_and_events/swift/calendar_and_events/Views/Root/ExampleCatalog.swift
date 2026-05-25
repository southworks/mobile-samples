import SwiftUI

struct ExampleSection: Identifiable {
    let id = UUID()
    let title: String
    let examples: [ExampleDescriptor]

    static let allSections: [ExampleSection] = [
        ExampleSection(
            title: "System Calendar / EventKit",
            examples: [
                .init(title: "CalendarPermissionExampleView", summary: "Solicita y explica los permisos del calendario real del iPhone.", concept: "Permisos y estados de acceso", systemImage: "lock.shield", destination: .permission),
                .init(title: "ReadTodayEventsExampleView", summary: "Lee los eventos de hoy desde EventKit.", concept: "Lectura de eventos del día", systemImage: "calendar.day.timeline.left", destination: .todayEvents),
                .init(title: "ReadNextSevenDaysEventsExampleView", summary: "Lee y agrupa eventos reales para los próximos siete días.", concept: "Rangos y agrupación por fecha", systemImage: "calendar.badge.clock", destination: .nextSevenDays),
                .init(title: "CreateSystemEventExampleView", summary: "Crea un evento real en el calendario por defecto.", concept: "Escritura directa con EventKit", systemImage: "square.and.pencil", destination: .createSystemEvent),
                .init(title: "NativeEventEditorExampleView", summary: "Presenta el editor nativo de iOS para crear o editar eventos.", concept: "EventKitUI y bridge con UIKit", systemImage: "slider.horizontal.3", destination: .nativeEditor),
                .init(title: "ObserveCalendarChangesExampleView", summary: "Escucha cambios del calendario del sistema y refresca la UI.", concept: "EKEventStoreChanged", systemImage: "arrow.triangle.2.circlepath", destination: .observeChanges),
                .init(title: "SystemCalendarsListExampleView", summary: "Lista los calendarios reales disponibles en el dispositivo.", concept: "Lectura de calendarios y metadatos", systemImage: "list.bullet.rectangle", destination: .systemCalendars)
            ]
        ),
        ExampleSection(
            title: "Custom App Calendar",
            examples: [
                .init(title: "CustomCalendarMonthExampleView", summary: "Muestra un calendario mensual propio con `UICalendarView`.", concept: "Calendario visual interno", systemImage: "calendar", destination: .customMonth),
                .init(title: "CustomCalendarEventsExampleView", summary: "Crea, edita y elimina eventos internos persistidos con SwiftData.", concept: "CRUD local de eventos", systemImage: "square.stack.3d.up", destination: .customEvents),
                .init(title: "CustomCalendarStorageExampleView", summary: "Explica y demuestra la persistencia local de eventos propios.", concept: "SwiftData y storage local", systemImage: "internaldrive", destination: .customStorage),
                .init(title: "CustomCalendarVsSystemCalendarExampleView", summary: "Compara calendario interno vs calendario del sistema.", concept: "Diferencias de arquitectura", systemImage: "square.split.2x1", destination: .comparison)
            ]
        )
    ]
}

struct ExampleDescriptor: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let concept: String
    let systemImage: String
    let destination: ExampleDestination
}

enum ExampleDestination: Hashable {
    case permission
    case todayEvents
    case nextSevenDays
    case createSystemEvent
    case nativeEditor
    case observeChanges
    case systemCalendars
    case customMonth
    case customEvents
    case customStorage
    case comparison

    @ViewBuilder
    func makeView() -> some View {
        switch self {
        case .permission:
            CalendarPermissionExampleView()
        case .todayEvents:
            ReadTodayEventsExampleView()
        case .nextSevenDays:
            ReadNextSevenDaysEventsExampleView()
        case .createSystemEvent:
            CreateSystemEventExampleView()
        case .nativeEditor:
            NativeEventEditorExampleView()
        case .observeChanges:
            ObserveCalendarChangesExampleView()
        case .systemCalendars:
            SystemCalendarsListExampleView()
        case .customMonth:
            CustomCalendarMonthExampleView()
        case .customEvents:
            CustomCalendarEventsExampleView()
        case .customStorage:
            CustomCalendarStorageExampleView()
        case .comparison:
            CustomCalendarVsSystemCalendarExampleView()
        }
    }
}
