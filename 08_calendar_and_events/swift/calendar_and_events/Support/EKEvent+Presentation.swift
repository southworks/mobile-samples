import EventKit

extension EKEvent {
    var displayTitle: String {
        title?.isEmpty == false ? title ?? "Sin título" : "Sin título"
    }
}
