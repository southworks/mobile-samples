import SwiftUI

struct CalendarPermissionExampleView: View {
    @Environment(CalendarManager.self) private var calendarManager
    @State private var viewModel: CalendarPermissionViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ExampleScreen(
                    title: "CalendarPermissionExampleView",
                    description: "Solicita y explica permisos del calendario real del iPhone usando EventKit."
                ) {
                    Section("Estado actual") {
                        StatusMessageView(
                            title: viewModel.status.title,
                            message: viewModel.status.message,
                            tint: color(for: viewModel.status)
                        )
                    }

                    Section("Acciones") {
                        Button(viewModel.isRequestInFlight ? "Solicitando..." : "Solicitar acceso completo") {
                            Task { await viewModel.requestFullAccess() }
                        }
                        .disabled(viewModel.isRequestInFlight)

                        Button("Refrescar estado") {
                            viewModel.refresh()
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Section("Error") {
                            StatusMessageView(title: "Solicitud fallida", message: errorMessage, tint: .red)
                        }
                    }

                    Section("Info.plist requerido") {
                        Text("Para iOS 17+ agregá `NSCalendarsFullAccessUsageDescription` para ejemplos de lectura y escritura.")
                        Text("Si la app implementa un flujo solo de escritura, agregá también `NSCalendarsWriteOnlyAccessUsageDescription`.")
                        Text("`requestAccess(to: .event)` está deprecado para iOS 17+. Usá `requestFullAccessToEvents()` para acceso completo.")
                    }

                    Section("Cuando el permiso está denegado") {
                        Text("La app no debe crashear. Mostrá el estado y guiá al usuario a Settings > Privacy & Security > Calendars.")
                    }
                }
            } else {
                ProgressView()
                    .task {
                        viewModel = CalendarPermissionViewModel(manager: calendarManager)
                    }
            }
        }
        .onAppear {
            viewModel?.refresh()
        }
    }

    private func color(for status: CalendarAuthorizationState) -> Color {
        switch status {
        case .fullAccess: .green
        case .writeOnly: .orange
        case .denied, .restricted, .unknown: .red
        case .notDetermined: .blue
        }
    }
}
