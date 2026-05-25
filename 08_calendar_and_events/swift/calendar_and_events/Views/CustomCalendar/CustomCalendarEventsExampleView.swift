import SwiftData
import SwiftUI

struct CustomCalendarEventsExampleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppCalendarEvent.startDate) private var events: [AppCalendarEvent]
    @State private var editorMode: AppCalendarEventEditorView.Mode?

    var body: some View {
        ExampleScreen(
            title: "CustomCalendarEventsExampleView",
            description: "CRUD completo de eventos internos usando SwiftData. No usa EventKit ni pide permisos."
        ) {
            Section("Acciones") {
                Button("Crear evento interno") {
                    editorMode = .create
                }
            }

            if events.isEmpty {
                Section("Estado vacío") {
                    Text("Todavía no hay eventos internos guardados en la app.")
                }
            } else {
                Section("Eventos internos") {
                    ForEach(events) { event in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Circle()
                                    .fill((AppEventColor(rawValue: event.colorName) ?? .sky).color)
                                    .frame(width: 10, height: 10)

                                Text(event.title)
                                    .font(.headline)
                            }

                            Text(event.isAllDay ? "Día completo" : "\(event.startDate.fullTimestamp()) - \(event.endDate.fullTimestamp())")
                                .font(.subheadline)

                            if !event.notes.isEmpty {
                                Text(event.notes)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions {
                            Button("Eliminar", role: .destructive) {
                                modelContext.delete(event)
                            }

                            Button("Editar") {
                                editorMode = .edit(event)
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .sheet(item: $editorMode) { mode in
            AppCalendarEventEditorView(mode: mode)
        }
    }
}
