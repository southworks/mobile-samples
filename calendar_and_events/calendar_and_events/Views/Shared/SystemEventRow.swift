import EventKit
import SwiftUI

struct SystemEventRow: View {
    let event: EKEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.displayTitle)
                .font(.headline)

            Text("\(event.startDate.fullTimestamp()) - \(event.endDate.fullTimestamp())")
                .font(.subheadline)

            Text("Calendario: \(event.calendar.title)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if event.isAllDay {
                Label("Evento de día completo", systemImage: "sun.max")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 2)
    }
}
