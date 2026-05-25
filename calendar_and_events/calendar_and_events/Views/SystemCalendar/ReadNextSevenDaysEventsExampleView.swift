import EventKit
import SwiftUI

struct ReadNextSevenDaysEventsExampleView: View {
    @Environment(CalendarManager.self) private var calendarManager
    @State private var viewModel: SystemEventsExampleViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ExampleScreen(
                    title: "ReadNextSevenDaysEventsExampleView",
                    description: "Lee eventos del calendario real desde hoy hasta los próximos siete días."
                ) {
                    Section("Acción") {
                        Button("Cargar próximos siete días") {
                            Task { await viewModel.load(interval: weekInterval()) }
                        }
                    }

                    if viewModel.isLoading {
                        Section {
                            ProgressView("Consultando EventKit...")
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Section("Error") {
                            StatusMessageView(title: "No se pudieron leer los eventos", message: errorMessage, tint: .red)
                        }
                    } else if viewModel.events.isEmpty {
                        Section("Estado vacío") {
                            Text("No hay eventos próximos o todavía no corriste la consulta.")
                        }
                    } else {
                        ForEach(groupedEvents(viewModel.events), id: \.date) { group in
                            Section(group.date.dayTitle()) {
                                ForEach(group.events, id: \.eventIdentifier) { event in
                                    SystemEventRow(event: event)
                                }
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

    private func weekInterval() -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start
        return DateInterval(start: start, end: end)
    }

    private func groupedEvents(_ events: [EKEvent]) -> [(date: Date, events: [EKEvent])] {
        let grouped = Dictionary(grouping: events) { Calendar.current.startOfDay(for: $0.startDate) }
        return grouped.keys.sorted().map { ($0, grouped[$0] ?? []) }
    }
}
