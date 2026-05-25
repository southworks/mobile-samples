import SwiftUI

struct CustomCalendarVsSystemCalendarExampleView: View {
    var body: some View {
        ExampleScreen(
            title: "CustomCalendarVsSystemCalendarExampleView",
            description: "Comparación visual entre datos internos de la app y eventos reales del sistema."
        ) {
            Section("System Calendar / EventKit") {
                ComparisonRow(title: "Permisos", value: "Sí, requeridos para leer o escribir con EventKit.")
                ComparisonRow(title: "Persistencia", value: "La administra iOS y las cuentas configuradas del usuario.")
                ComparisonRow(title: "Visibilidad", value: "Aparece en la app Calendario de iOS y otras apps autorizadas.")
                ComparisonRow(title: "Tecnología", value: "EventKit y opcionalmente EventKitUI.")
                ComparisonRow(title: "Sincronización", value: "La define el ecosistema del usuario: iCloud, Exchange, Google, etc.")
            }

            Section("Custom App Calendar") {
                ComparisonRow(title: "Permisos", value: "No requiere permisos de calendario.")
                ComparisonRow(title: "Persistencia", value: "SwiftData local dentro del sandbox de la app.")
                ComparisonRow(title: "Visibilidad", value: "Solo existe dentro de esta app.")
                ComparisonRow(title: "Tecnología", value: "SwiftData + SwiftUI + `UICalendarView` como componente visual.")
                ComparisonRow(title: "Sincronización", value: "Puede integrarse con backend propio en el futuro.")
            }
        }
    }
}

private struct ComparisonRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
