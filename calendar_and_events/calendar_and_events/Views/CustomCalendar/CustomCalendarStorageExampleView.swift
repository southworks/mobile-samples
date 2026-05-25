import SwiftData
import SwiftUI

struct CustomCalendarStorageExampleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppCalendarEvent.createdAt, order: .reverse) private var events: [AppCalendarEvent]

    var body: some View {
        ExampleScreen(
            title: "CustomCalendarStorageExampleView",
            description: "Demuestra cómo SwiftData persiste eventos internos de la app entre lanzamientos."
        ) {
            Section("Explicación") {
                Text("Estos eventos viven en el storage local de la app. No aparecen en Calendario de iOS.")
                Text("Si el usuario borra la app, estos datos también se eliminan, salvo que se implemente sincronización externa en el futuro.")
            }

            Section("Acciones rápidas") {
                Button("Crear evento de muestra") {
                    let startDate = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
                    let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate) ?? startDate
                    modelContext.insert(
                        AppCalendarEvent(
                            title: "Evento local \(events.count + 1)",
                            startDate: startDate,
                            endDate: endDate,
                            notes: "Persistido con SwiftData.",
                            colorName: AppEventColor.mint.rawValue
                        )
                    )
                }

                Button("Eliminar todos", role: .destructive) {
                    events.forEach { modelContext.delete($0) }
                }
                .disabled(events.isEmpty)
            }

            if events.isEmpty {
                Section("Estado vacío") {
                    Text("No hay eventos persistidos en este momento.")
                }
            } else {
                Section("Eventos persistidos") {
                    ForEach(events) { event in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(event.title)
                                .font(.headline)
                            Text("Creado: \(event.createdAt.fullTimestamp())")
                                .font(.subheadline)
                            Text("Actualizado: \(event.updatedAt.fullTimestamp())")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
        }
    }

    private func delete(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(events[index])
        }
    }
}
