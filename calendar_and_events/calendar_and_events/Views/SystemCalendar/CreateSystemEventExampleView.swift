import SwiftUI

struct CreateSystemEventExampleView: View {
    @Environment(CalendarManager.self) private var calendarManager
    @State private var viewModel: CreateSystemEventViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ExampleScreen(
                    title: "CreateSystemEventExampleView",
                    description: "Crea un evento real que luego aparece en la app Calendario de iOS."
                ) {
                    Section("Formulario") {
                        TextField("Título", text: binding(get: { viewModel.draft.title }, set: { viewModel.draft.title = $0 }))
                        Toggle("Día completo", isOn: binding(get: { viewModel.draft.isAllDay }, set: { viewModel.draft.isAllDay = $0 }))
                        DatePicker(
                            "Inicio",
                            selection: binding(get: { viewModel.draft.startDate }, set: { viewModel.draft.startDate = $0 }),
                            displayedComponents: viewModel.draft.isAllDay ? [.date] : [.date, .hourAndMinute]
                        )
                        DatePicker(
                            "Fin",
                            selection: binding(get: { viewModel.draft.endDate }, set: { viewModel.draft.endDate = $0 }),
                            displayedComponents: viewModel.draft.isAllDay ? [.date] : [.date, .hourAndMinute]
                        )
                        TextField("Notas", text: binding(get: { viewModel.draft.notes }, set: { viewModel.draft.notes = $0 }), axis: .vertical)
                            .lineLimit(3...5)
                    }

                    Section("Guardar") {
                        Button(viewModel.isSaving ? "Guardando..." : "Guardar en calendario por defecto") {
                            Task { await viewModel.save() }
                        }
                        .disabled(viewModel.isSaving)

                        Text("Este ejemplo usa EventKit directamente y guarda un evento real del sistema.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let resultMessage = viewModel.resultMessage {
                        Section("Resultado") {
                            StatusMessageView(title: "Guardado correcto", message: resultMessage, tint: .green)
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Section("Error") {
                            StatusMessageView(title: "No se pudo guardar", message: errorMessage, tint: .red)
                        }
                    }
                }
            } else {
                ProgressView()
                    .task {
                        viewModel = CreateSystemEventViewModel(manager: calendarManager)
                    }
            }
        }
    }

    private func binding<Value>(get: @escaping () -> Value, set: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: get, set: set)
    }
}
