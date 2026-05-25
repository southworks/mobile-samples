import SwiftData
import SwiftUI

struct AppCalendarEventEditorView: View {
    enum Mode: Identifiable {
        case create
        case edit(AppCalendarEvent)

        var id: String {
            switch self {
            case .create:
                "create"
            case .edit(let event):
                event.id.uuidString
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let mode: Mode
    @State private var draft: AppCalendarEventDraft
    @State private var errorMessage: String?

    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .create:
            _draft = State(initialValue: AppCalendarEventDraft())
        case .edit(let event):
            _draft = State(initialValue: AppCalendarEventDraft(event: event))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos") {
                    TextField("Título", text: $draft.title)

                    Toggle("Día completo", isOn: $draft.isAllDay)

                    DatePicker("Inicio", selection: $draft.startDate, displayedComponents: draft.isAllDay ? [.date] : [.date, .hourAndMinute])
                    DatePicker("Fin", selection: $draft.endDate, displayedComponents: draft.isAllDay ? [.date] : [.date, .hourAndMinute])
                }

                Section("Detalles") {
                    Picker("Color", selection: $draft.color) {
                        ForEach(AppEventColor.allCases) { color in
                            Label(color.title, systemImage: "circle.fill")
                                .foregroundStyle(color.color)
                                .tag(color)
                        }
                    }

                    TextField("Notas", text: $draft.notes, axis: .vertical)
                        .lineLimit(3...5)
                }

                if let errorMessage {
                    Section("Error") {
                        StatusMessageView(title: "No se pudo guardar", message: errorMessage, tint: .red)
                    }
                }
            }
            .navigationTitle(modeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                }
            }
        }
    }

    private var modeTitle: String {
        switch mode {
        case .create: "Nuevo evento interno"
        case .edit: "Editar evento interno"
        }
    }

    private func save() {
        do {
            draft.normalizeAllDayDates()
            try draft.validate()

            switch mode {
            case .create:
                let event = AppCalendarEvent(
                    title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    startDate: draft.startDate,
                    endDate: draft.endDate,
                    notes: draft.notes,
                    colorName: draft.color.rawValue,
                    isAllDay: draft.isAllDay
                )
                modelContext.insert(event)
            case .edit(let event):
                event.apply(draft: draft)
            }

            errorMessage = nil
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
