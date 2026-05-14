//
//  BoardModels.swift
//  canvas_samples
//
//  Created by Codex on 5/14/26.
//

import Foundation
import UIKit

enum BoardInteractionMode: String, CaseIterable, Identifiable {
    case select
    case draw
    case rectangle
    case roundedRectangle
    case ellipse
    case text
    case arrow

    var id: Self { self }

    var title: String {
        switch self {
        case .select: "Select"
        case .draw: "Draw"
        case .rectangle: "Rect"
        case .roundedRectangle: "Rounded"
        case .ellipse: "Ellipse"
        case .text: "Text"
        case .arrow: "Arrow"
        }
    }

    var systemImage: String {
        switch self {
        case .select: "cursorarrow"
        case .draw: "pencil.tip"
        case .rectangle: "rectangle"
        case .roundedRectangle: "capsule.portrait"
        case .ellipse: "oval"
        case .text: "textformat"
        case .arrow: "arrowshape.right"
        }
    }
}

enum BoardItemKind: String, Codable, CaseIterable {
    case rectangle
    case roundedRectangle
    case ellipse
    case text
    case arrow
}

enum ArrowAnchor: String, Codable, CaseIterable {
    case top
    case trailing
    case bottom
    case leading
    case center
}

enum ResizeHandle: CaseIterable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

struct BoardColor: Codable, Equatable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(_ color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    static let accent = BoardColor(UIColor.systemBlue)
    static let accentFill = BoardColor(UIColor.systemBlue.withAlphaComponent(0.12))
    static let orange = BoardColor(UIColor.systemOrange)
    static let orangeFill = BoardColor(UIColor.systemOrange.withAlphaComponent(0.14))
    static let text = BoardColor(UIColor.label)
    static let clear = BoardColor(UIColor.clear)
}

struct BoardItemStyle: Codable, Equatable {
    var stroke: BoardColor
    var fill: BoardColor
    var text: BoardColor
    var lineWidth: CGFloat

    static let rectangleDefault = BoardItemStyle(
        stroke: .accent,
        fill: .accentFill,
        text: .text,
        lineWidth: 3
    )

    static let roundedDefault = BoardItemStyle(
        stroke: .orange,
        fill: .orangeFill,
        text: .text,
        lineWidth: 3
    )

    static let ellipseDefault = BoardItemStyle(
        stroke: BoardColor(UIColor.systemGreen),
        fill: BoardColor(UIColor.systemGreen.withAlphaComponent(0.12)),
        text: .text,
        lineWidth: 3
    )

    static let textDefault = BoardItemStyle(
        stroke: .clear,
        fill: .clear,
        text: .text,
        lineWidth: 0
    )

    static let arrowDefault = BoardItemStyle(
        stroke: .text,
        fill: .clear,
        text: .text,
        lineWidth: 4
    )
}

struct BoardItem: Identifiable, Codable, Equatable {
    var id: UUID
    var kind: BoardItemKind
    var frame: CGRect
    var style: BoardItemStyle
    var text: String?
    var zIndex: Double
    var sourceItemID: UUID?
    var targetItemID: UUID?
    var sourceAnchor: ArrowAnchor?
    var targetAnchor: ArrowAnchor?

    var isConnectable: Bool { kind != .arrow }
    var isResizable: Bool { kind != .arrow }
    var isTextEditable: Bool { kind == .text }
    var displayText: String { (text?.isEmpty == false ? text : "Label") ?? "Label" }

    static func makeShape(kind: BoardItemKind, centeredAt point: CGPoint, zIndex: Double) -> BoardItem {
        let size = CGSize(width: 260, height: 160)
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
        let style: BoardItemStyle = switch kind {
        case .rectangle: .rectangleDefault
        case .roundedRectangle: .roundedDefault
        case .ellipse: .ellipseDefault
        case .text, .arrow: .rectangleDefault
        }

        return BoardItem(
            id: UUID(),
            kind: kind,
            frame: CGRect(origin: origin, size: size),
            style: style,
            text: nil,
            zIndex: zIndex
        )
    }

    static func makeText(centeredAt point: CGPoint, zIndex: Double) -> BoardItem {
        let size = CGSize(width: 280, height: 90)
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
        return BoardItem(
            id: UUID(),
            kind: .text,
            frame: CGRect(origin: origin, size: size),
            style: .textDefault,
            text: "Nuevo label",
            zIndex: zIndex
        )
    }

    static func makeArrow(
        source: BoardItem,
        target: BoardItem,
        anchors: (ArrowAnchor, ArrowAnchor),
        zIndex: Double
    ) -> BoardItem {
        let start = BoardGeometry.anchorPoint(for: source, anchor: anchors.0)
        let end = BoardGeometry.anchorPoint(for: target, anchor: anchors.1)
        return BoardItem(
            id: UUID(),
            kind: .arrow,
            frame: CGRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(start.x - end.x),
                height: abs(start.y - end.y)
            ),
            style: .arrowDefault,
            text: nil,
            zIndex: zIndex,
            sourceItemID: source.id,
            targetItemID: target.id,
            sourceAnchor: anchors.0,
            targetAnchor: anchors.1
        )
    }
}

struct BoardDocumentPayload: Codable, Equatable {
    var items: [BoardItem] = []
}

enum BoardGeometry {
    static func anchorPoint(for item: BoardItem, anchor: ArrowAnchor) -> CGPoint {
        switch anchor {
        case .top:
            CGPoint(x: item.frame.midX, y: item.frame.minY)
        case .trailing:
            CGPoint(x: item.frame.maxX, y: item.frame.midY)
        case .bottom:
            CGPoint(x: item.frame.midX, y: item.frame.maxY)
        case .leading:
            CGPoint(x: item.frame.minX, y: item.frame.midY)
        case .center:
            CGPoint(x: item.frame.midX, y: item.frame.midY)
        }
    }

    static func bestAnchors(from source: BoardItem, to target: BoardItem) -> (ArrowAnchor, ArrowAnchor) {
        let candidates = [ArrowAnchor.top, .trailing, .bottom, .leading]
        var bestPair = (ArrowAnchor.trailing, ArrowAnchor.leading)
        var bestDistance = CGFloat.greatestFiniteMagnitude

        for sourceAnchor in candidates {
            for targetAnchor in candidates {
                let sourcePoint = anchorPoint(for: source, anchor: sourceAnchor)
                let targetPoint = anchorPoint(for: target, anchor: targetAnchor)
                let distance = hypot(sourcePoint.x - targetPoint.x, sourcePoint.y - targetPoint.y)
                if distance < bestDistance {
                    bestDistance = distance
                    bestPair = (sourceAnchor, targetAnchor)
                }
            }
        }

        return bestPair
    }

    static func arrowEndpoints(for arrow: BoardItem, itemsByID: [UUID: BoardItem]) -> (CGPoint, CGPoint)? {
        guard
            let sourceID = arrow.sourceItemID,
            let targetID = arrow.targetItemID,
            let source = itemsByID[sourceID],
            let target = itemsByID[targetID]
        else {
            return nil
        }

        let sourceAnchor = arrow.sourceAnchor ?? .trailing
        let targetAnchor = arrow.targetAnchor ?? .leading
        return (
            anchorPoint(for: source, anchor: sourceAnchor),
            anchorPoint(for: target, anchor: targetAnchor)
        )
    }

    static func selectionHandleFrames(for frame: CGRect, zoomScale: CGFloat) -> [ResizeHandle: CGRect] {
        let size = max(14 / max(zoomScale, 0.25), 8)
        let half = size / 2
        return [
            .topLeading: CGRect(x: frame.minX - half, y: frame.minY - half, width: size, height: size),
            .topTrailing: CGRect(x: frame.maxX - half, y: frame.minY - half, width: size, height: size),
            .bottomLeading: CGRect(x: frame.minX - half, y: frame.maxY - half, width: size, height: size),
            .bottomTrailing: CGRect(x: frame.maxX - half, y: frame.maxY - half, width: size, height: size),
        ]
    }
}
