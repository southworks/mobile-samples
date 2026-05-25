import SwiftUI

struct SystemCalendarsListExampleView: View {
    @Environment(CalendarManager.self) private var calendarManager
    @State private var viewModel: SystemCalendarsListViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ExampleScreen(
                    title: "SystemCalendarsListExampleView",
                    description: "Lee calendarios disponibles para eventos y expone metadatos útiles."
                ) {
                    Section("Acción") {
                        Button("Cargar calendarios del sistema") {
                            viewModel.load()
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Section("Error") {
                            StatusMessageView(title: "No se pudo leer la lista", message: errorMessage, tint: .red)
                        }
                    } else if viewModel.calendars.isEmpty {
                        Section("Estado vacío") {
                            Text("Todavía no cargaste la lista o el sistema no devolvió calendarios.")
                        }
                    } else {
                        Section("Calendarios") {
                            ForEach(viewModel.calendars, id: \.calendarIdentifier) { calendar in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Circle()
                                            .fill(calendar.swiftUIColor)
                                            .frame(width: 12, height: 12)

                                        Text(calendar.title)
                                            .font(.headline)
                                    }

                                    Text("Tipo: \(calendar.typeDisplayName)")
                                    Text("Permite modificaciones: \(calendar.allowsContentModifications ? "Sí" : "No")")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
            } else {
                ProgressView()
                    .task {
                        viewModel = SystemCalendarsListViewModel(manager: calendarManager)
                    }
            }
        }
    }
}
