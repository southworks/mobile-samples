import SwiftUI

struct RootView: View {
    private let sections = ExampleSection.allSections

    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.examples) { example in
                            NavigationLink(value: example.destination) {
                                ExampleRow(example: example)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Calendar Gallery")
            .navigationDestination(for: ExampleDestination.self) { destination in
                destination.makeView()
            }
        }
    }
}

private struct ExampleRow: View {
    let example: ExampleDescriptor

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(example.title)
                .font(.headline)

            Text(example.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(example.concept, systemImage: example.systemImage)
                .font(.caption)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RootView()
        .environment(CalendarManager())
        .modelContainer(for: AppCalendarEvent.self, inMemory: true)
}
