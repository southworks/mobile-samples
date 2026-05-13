//
//  SavedDrawing.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import Foundation
import PencilKit
import SwiftData

@Model
final class SavedDrawing {
    var title: String
    var createdAt: Date
    var updatedAt: Date

    @Attribute(.externalStorage)
    var drawingData: Data

    init(
        title: String = "SwiftData example",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        drawingData: Data = PKDrawing().dataRepresentation()
    ) {
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.drawingData = drawingData
    }

    var drawing: PKDrawing {
        (try? PKDrawing(data: drawingData)) ?? PKDrawing()
    }
}
