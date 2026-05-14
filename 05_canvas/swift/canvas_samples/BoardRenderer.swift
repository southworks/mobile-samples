//
//  BoardRenderer.swift
//  canvas_samples
//
//  Created by Codex on 5/14/26.
//

import Foundation
import PencilKit
import UIKit

enum BoardSceneRenderer {
    static func draw(
        items: [BoardItem],
        selectedItemID: UUID? = nil,
        pendingArrowSourceID: UUID? = nil,
        in context: CGContext,
        zoomScale: CGFloat
    ) {
        let itemsByID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        let arrows = items.filter { $0.kind == .arrow }.sorted { $0.zIndex < $1.zIndex }
        let nodes = items.filter { $0.kind != .arrow }.sorted { $0.zIndex < $1.zIndex }

        for arrow in arrows {
            drawArrow(arrow, itemsByID: itemsByID, in: context, selected: arrow.id == selectedItemID)
        }

        for item in nodes {
            drawNode(item, in: context, selected: item.id == selectedItemID)
        }

        if let pendingArrowSourceID, let source = itemsByID[pendingArrowSourceID], source.kind != .arrow {
            let outline = UIBezierPath(roundedRect: source.frame.insetBy(dx: -8, dy: -8), cornerRadius: 20)
            UIColor.systemRed.setStroke()
            outline.setLineDash([18 / max(zoomScale, 0.25), 10 / max(zoomScale, 0.25)], count: 2, phase: 0)
            outline.lineWidth = max(3 / max(zoomScale, 0.25), 1.5)
            outline.stroke()
        }
    }

    private static func drawNode(_ item: BoardItem, in context: CGContext, selected: Bool) {
        let path = shapePath(for: item)
        item.style.fill.uiColor.setFill()
        path.fill()

        let strokeColor = selected ? UIColor.systemRed : item.style.stroke.uiColor
        strokeColor.setStroke()
        path.lineWidth = max(item.style.lineWidth, selected ? item.style.lineWidth + 1 : item.style.lineWidth)
        path.stroke()

        if item.kind == .text {
            drawText(item.displayText, in: item.frame, color: item.style.text.uiColor, selected: selected)
        }

        if selected && item.isResizable {
            drawSelection(frame: item.frame, zoomScale: context.ctm.a)
        }
    }

    private static func drawArrow(_ arrow: BoardItem, itemsByID: [UUID: BoardItem], in context: CGContext, selected: Bool) {
        guard let (start, end) = BoardGeometry.arrowEndpoints(for: arrow, itemsByID: itemsByID) else { return }
        let color = selected ? UIColor.systemRed : arrow.style.stroke.uiColor
        let lineWidth = max(arrow.style.lineWidth, selected ? arrow.style.lineWidth + 1 : arrow.style.lineWidth)

        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        color.setStroke()
        path.stroke()

        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowHeadLength = max(24 / max(context.ctm.a, 0.25), 12)
        let arrowHead = UIBezierPath()
        arrowHead.move(to: end)
        arrowHead.addLine(to: CGPoint(
            x: end.x - arrowHeadLength * cos(angle - .pi / 8),
            y: end.y - arrowHeadLength * sin(angle - .pi / 8)
        ))
        arrowHead.addLine(to: CGPoint(
            x: end.x - arrowHeadLength * cos(angle + .pi / 8),
            y: end.y - arrowHeadLength * sin(angle + .pi / 8)
        ))
        arrowHead.close()
        color.setFill()
        arrowHead.fill()
    }

    private static func shapePath(for item: BoardItem) -> UIBezierPath {
        switch item.kind {
        case .rectangle:
            UIBezierPath(rect: item.frame)
        case .roundedRectangle:
            UIBezierPath(roundedRect: item.frame, cornerRadius: 28)
        case .ellipse:
            UIBezierPath(ovalIn: item.frame)
        case .text:
            UIBezierPath(roundedRect: item.frame.insetBy(dx: -6, dy: -4), cornerRadius: 18)
        case .arrow:
            UIBezierPath()
        }
    }

    private static func drawSelection(frame: CGRect, zoomScale: CGFloat) {
        let outline = UIBezierPath(roundedRect: frame.insetBy(dx: -6 / max(zoomScale, 0.25), dy: -6 / max(zoomScale, 0.25)), cornerRadius: 18 / max(zoomScale, 0.25))
        UIColor.systemRed.setStroke()
        outline.lineWidth = max(2 / max(zoomScale, 0.25), 1)
        outline.stroke()

        for handleFrame in BoardGeometry.selectionHandleFrames(for: frame, zoomScale: zoomScale).values {
            let handlePath = UIBezierPath(roundedRect: handleFrame, cornerRadius: handleFrame.width / 3)
            UIColor.systemBackground.setFill()
            UIColor.systemRed.setStroke()
            handlePath.lineWidth = max(2 / max(zoomScale, 0.25), 1)
            handlePath.fill()
            handlePath.stroke()
        }
    }

    private static func drawText(_ text: String, in frame: CGRect, color: UIColor, selected: Bool) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let font = UIFont.preferredFont(forTextStyle: selected ? .title3 : .headline)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph,
        ]
        let textRect = frame.insetBy(dx: 16, dy: 14)
        text.draw(with: textRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
    }
}

enum BoardExporter {
    static let fallbackBounds = CGRect(x: 19_400, y: 19_600, width: 1_200, height: 800)

    static func pngData(drawing: PKDrawing, items: [BoardItem]) -> Data? {
        composedImage(drawing: drawing, items: items).pngData()
    }

    static func pdfData(drawing: PKDrawing, items: [BoardItem]) -> Data {
        let bounds = exportBounds(drawing: drawing, items: items)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: bounds.size))
        return renderer.pdfData { context in
            context.beginPage()
            let cgContext = context.cgContext
            fillBackground(in: cgContext, size: bounds.size)
            let image = drawing.image(from: bounds, scale: 1)
            image.draw(in: CGRect(origin: .zero, size: bounds.size))
            cgContext.saveGState()
            cgContext.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
            BoardSceneRenderer.draw(items: items, in: cgContext, zoomScale: 1)
            cgContext.restoreGState()
        }
    }

    private static func composedImage(drawing: PKDrawing, items: [BoardItem]) -> UIImage {
        let bounds = exportBounds(drawing: drawing, items: items)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 2
        format.opaque = true
        return UIGraphicsImageRenderer(size: bounds.size, format: format).image { context in
            fillBackground(in: context.cgContext, size: bounds.size)
            let image = drawing.image(from: bounds, scale: 1)
            image.draw(in: CGRect(origin: .zero, size: bounds.size))
            context.cgContext.saveGState()
            context.cgContext.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
            BoardSceneRenderer.draw(items: items, in: context.cgContext, zoomScale: 1)
            context.cgContext.restoreGState()
        }
    }

    private static func exportBounds(drawing: PKDrawing, items: [BoardItem]) -> CGRect {
        var bounds = drawing.bounds.isNull ? CGRect.null : drawing.bounds.insetBy(dx: -120, dy: -120)
        let lookup = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })

        for item in items {
            let itemBounds: CGRect = if item.kind == .arrow, let (start, end) = BoardGeometry.arrowEndpoints(for: item, itemsByID: lookup) {
                CGRect(
                    x: min(start.x, end.x),
                    y: min(start.y, end.y),
                    width: abs(start.x - end.x),
                    height: abs(start.y - end.y)
                ).insetBy(dx: -60, dy: -60)
            } else {
                item.frame.insetBy(dx: -40, dy: -40)
            }

            bounds = bounds.isNull ? itemBounds : bounds.union(itemBounds)
        }

        if bounds.isNull || bounds.isEmpty {
            return fallbackBounds
        }

        return bounds.standardized
    }

    private static func fillBackground(in context: CGContext, size: CGSize) {
        UIColor.systemBackground.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ExportedFile: Identifiable {
    let id = UUID()
    let url: URL
}
