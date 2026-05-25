import EventKit
import EventKitUI
import SwiftUI

struct SystemEventEditorSheet: UIViewControllerRepresentable {
    enum EventSource: Identifiable {
        case new
        case existing(EKEvent)

        var id: String {
            switch self {
            case .new:
                "new"
            case .existing(let event):
                event.eventIdentifier ?? UUID().uuidString
            }
        }
    }

    let manager: CalendarManager
    let source: EventSource
    let onComplete: (EKEventEditViewAction) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = manager.editorEventStore()
        controller.editViewDelegate = context.coordinator

        switch source {
        case .new:
            controller.event = manager.newEvent()
        case .existing(let event):
            controller.event = event
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let onComplete: (EKEventEditViewAction) -> Void

        init(onComplete: @escaping (EKEventEditViewAction) -> Void) {
            self.onComplete = onComplete
        }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            onComplete(action)
            controller.dismiss(animated: true)
        }
    }
}
