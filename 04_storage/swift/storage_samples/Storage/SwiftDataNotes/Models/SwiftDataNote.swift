import Foundation
import SwiftData

@Model
final class SwiftDataNote {
    var title: String

    init(title: String) {
        self.title = title
    }
}
