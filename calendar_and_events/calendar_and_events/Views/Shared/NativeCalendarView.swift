import SwiftUI
import UIKit

struct NativeCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?
    let decoratedDates: Set<DateComponents>

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.calendar = .current
        view.locale = .current
        view.fontDesign = .rounded

        let selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = selectionBehavior

        if let selectedDate {
            selectionBehavior.setSelected(context.coordinator.dayComponents(for: selectedDate), animated: false)
        }

        context.coordinator.decoratedDates = decoratedDates
        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.parent = self
        let previousDates = context.coordinator.decoratedDates
        context.coordinator.decoratedDates = decoratedDates

        let datesToReload = Array(Set(previousDates).union(decoratedDates))
        if !datesToReload.isEmpty {
            uiView.reloadDecorations(forDateComponents: datesToReload, animated: true)
        }

        if let selectionBehavior = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            if let selectedDate {
                selectionBehavior.setSelected(context.coordinator.dayComponents(for: selectedDate), animated: true)
            } else {
                selectionBehavior.setSelected(nil, animated: true)
            }
        }
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: NativeCalendarView
        var decoratedDates: Set<DateComponents> = []

        init(parent: NativeCalendarView) {
            self.parent = parent
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.selectedDate = dateComponents?.date
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard decoratedDates.contains(dateComponents) else { return nil }

            return .customView {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                view.backgroundColor = UIColor.systemBlue
                view.layer.cornerRadius = 5
                return view
            }
        }

        func dayComponents(for date: Date) -> DateComponents {
            Calendar.current.dateComponents([.year, .month, .day], from: date)
        }
    }
}
