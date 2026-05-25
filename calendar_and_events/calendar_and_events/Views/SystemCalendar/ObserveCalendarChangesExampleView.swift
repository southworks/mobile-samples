import SwiftUI

struct ObserveCalendarChangesExampleView: View {
    @Environment(CalendarManager.self) private var calendarManager
    @State private var viewModel: ObserveCalendarChangesViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ExampleScreen(
                    title: "ObserveCalendarChangesExampleView",
                    description: "Escucha `EKEventStoreChanged` y refresca automáticamente una lista de eventos próximos."
                ) {
                    Section("Estado") {
                        Text("Último refresh: \(viewModel.lastRefreshAt?.fullTimestamp() ?? "Nunca")")
                        Button("Refrescar manualmente") {
                            viewModel.refresh()
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Section("Error") {
                            StatusMessageView(title: "No se pudieron cargar eventos", message: errorMessage, tint: .red)
                        }
                    } else if viewModel.events.isEmpty {
                        Section("Estado vacío") {
                            Text("No hay eventos próximos o no hay permiso de lectura.")
                        }
                    } else {
                        Section("Próximos eventos") {
                            ForEach(viewModel.events, id: \.eventIdentifier) { event in
                                SystemEventRow(event: event)
                            }
                        }
                    }
                }
                .task {
                    viewModel.refresh()
                    for await _ in viewModel.listenForChanges() {
                        viewModel.refresh()
                    }
                }
            } else {
                ProgressView()
                    .task {
                        viewModel = ObserveCalendarChangesViewModel(manager: calendarManager)
                    }
            }
        }
    }
}
