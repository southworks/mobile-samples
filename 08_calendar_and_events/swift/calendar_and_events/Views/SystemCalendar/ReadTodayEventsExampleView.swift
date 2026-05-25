import Foundation
import SwiftUI

struct ReadTodayEventsExampleView: View {
    @Environment(CalendarManager.self) private var calendarManager
    @State private var viewModel: SystemEventsExampleViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ExampleScreen(
                    title: "ReadTodayEventsExampleView",
                    description: "Lee eventos reales del día actual desde EventKit."
                ) {
                    Section("Acción") {
                        Button("Cargar eventos de hoy") {
                            Task { await viewModel.load(interval: todayInterval()) }
                        }

                        if let lastLoadedAt = viewModel.lastLoadedAt {
                            Text("Última carga: \(lastLoadedAt.fullTimestamp())")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if viewModel.isLoading {
                        Section {
                            ProgressView("Leyendo calendario del sistema...")
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Section("Error") {
                            StatusMessageView(title: "No se pudieron leer eventos", message: errorMessage, tint: .red)
                        }
                    } else if viewModel.events.isEmpty {
                        Section("Estado vacío") {
                            Text("No hay eventos para hoy o todavía no cargaste la lista.")
                        }
                    } else {
                        Section("Eventos encontrados") {
                            ForEach(viewModel.events, id: \.eventIdentifier) { event in
                                SystemEventRow(event: event)
                            }
                        }
                    }
                }
            } else {
                ProgressView()
                    .task {
                        viewModel = SystemEventsExampleViewModel(manager: calendarManager)
                    }
            }
        }
    }

    private func todayInterval() -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return DateInterval(start: start, end: end)
    }
}
