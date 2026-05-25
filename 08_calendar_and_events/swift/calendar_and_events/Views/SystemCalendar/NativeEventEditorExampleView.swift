import EventKit
import EventKitUI
import SwiftUI

struct NativeEventEditorExampleView: View {
    @Environment(CalendarManager.self) private var calendarManager
    @State private var editorSource: SystemEventEditorSheet.EventSource?
    @State private var callbackMessage = "Todavía no se abrió el editor."
    @State private var loadError: String?

    var body: some View {
        ExampleScreen(
            title: "NativeEventEditorExampleView",
            description: "Presenta `EKEventEditViewController` usando `UIViewControllerRepresentable`."
        ) {
            Section("Acciones") {
                Button("Abrir editor nativo para evento nuevo") {
                    loadError = nil
                    editorSource = .new
                }

                Button("Editar primer evento próximo") {
                    do {
                        editorSource = .existing(try calendarManager.editableUpcomingEvent())
                        loadError = nil
                    } catch {
                        loadError = error.localizedDescription
                    }
                }

                Text("Apple permite usar la UI nativa de edición incluso si la app no leyó calendarios previamente.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Callback") {
                Text(callbackMessage)
            }

            if let loadError {
                Section("Error") {
                    StatusMessageView(title: "No se pudo abrir el editor", message: loadError, tint: .red)
                }
            }
        }
        .sheet(item: $editorSource, onDismiss: { editorSource = nil }) { source in
            SystemEventEditorSheet(manager: calendarManager, source: source) { action in
                callbackMessage = message(for: action)
                editorSource = nil
            }
        }
    }

    private func message(for action: EKEventEditViewAction) -> String {
        switch action {
        case .canceled:
            "El usuario canceló la edición."
        case .saved:
            "El usuario guardó el evento desde la UI nativa."
        case .deleted:
            "El usuario eliminó el evento desde la UI nativa."
        @unknown default:
            "La UI nativa devolvió un resultado no reconocido."
        }
    }
}
