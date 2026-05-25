import Foundation

extension Date {
    func dayTitle() -> String {
        formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    func fullTimestamp() -> String {
        formatted(.dateTime.day().month(.abbreviated).year().hour().minute())
    }

    func shortTime() -> String {
        formatted(.dateTime.hour().minute())
    }
}
