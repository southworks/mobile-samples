import SwiftData
import SwiftUI

struct CustomCalendarMonthExampleView: View {
    @Query(sort: \AppCalendarEvent.startDate) private var events: [AppCalendarEvent]
    @State private var selectedDate: Date? = .now

    var body: some View {
        ExampleScreen(
            title: "CustomCalendarMonthExampleView",
            description: "Usa `UICalendarView` como calendario mensual visual para eventos internos persistidos con SwiftData."
        ) {
            Section("Calendario mensual") {
                NativeCalendarView(
                    selectedDate: $selectedDate,
                    decoratedDates: decoratedDates
                )
                .frame(height: 360)

                Text("`UICalendarView` solo muestra y selecciona fechas. Los eventos siguen siendo datos propios de la app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Fecha seleccionada") {
                Text(selectedDate?.dayTitle() ?? "No hay fecha seleccionada")
            }

            if eventsForSelectedDay.isEmpty {
                Section("Estado vacío") {
                    Text("No hay eventos internos para el día seleccionado.")
                }
            } else {
                Section("Eventos internos del día") {
                    ForEach(eventsForSelectedDay) { event in
                        VStack(alignment: .leading, spacing: 6) {
                            Label(event.title, systemImage: "circle.fill")
                                .foregroundStyle((AppEventColor(rawValue: event.colorName) ?? .sky).color)

                            Text(event.isAllDay ? "Día completo" : "\(event.startDate.shortTime()) - \(event.endDate.shortTime())")
                                .foregroundStyle(.secondary)

                            if !event.notes.isEmpty {
                                Text(event.notes)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
        }
    }

    private var decoratedDates: Set<DateComponents> {
        Set(events.map { Calendar.current.dateComponents([.year, .month, .day], from: $0.startDate) })
    }

    private var eventsForSelectedDay: [AppCalendarEvent] {
        guard let selectedDate else { return [] }

        return events.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate)
        }
    }
}
