//
//  BoardDocument.swift
//  canvas_samples
//
//  Created by Codex on 5/14/26.
//

import Foundation
import PencilKit
import SwiftData

@Model
final class BoardDocument {
    var title: String
    var createdAt: Date
    var updatedAt: Date

    @Attribute(.externalStorage)
    var drawingData: Data

    @Attribute(.externalStorage)
    var boardItemsData: Data

    init(
        title: String = "Untitled board",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        drawingData: Data = PKDrawing().dataRepresentation(),
        boardItemsData: Data = (try? JSONEncoder().encode(BoardDocumentPayload())) ?? Data()
    ) {
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.drawingData = drawingData
        self.boardItemsData = boardItemsData
    }

    var drawing: PKDrawing {
        (try? PKDrawing(data: drawingData)) ?? PKDrawing()
    }

    var boardItems: [BoardItem] {
        guard let payload = try? JSONDecoder().decode(BoardDocumentPayload.self, from: boardItemsData) else { return [] }
        return payload.items
    }

    func update(title: String, drawing: PKDrawing, items: [BoardItem]) {
        self.title = title
        self.updatedAt = .now
        self.drawingData = drawing.dataRepresentation()
        self.boardItemsData = (try? JSONEncoder().encode(BoardDocumentPayload(items: items))) ?? Data()
    }
}
