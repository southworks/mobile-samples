//
//  PencilCanvasView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import PencilKit
import SwiftUI

@MainActor
final class MassiveCanvasController: ObservableObject {
    weak var canvasView: PKCanvasView?
    var onDrawingChange: ((PKDrawing) -> Void)?

    func insertRectangle() {
        insertShape(points: ShapeFactory.rectangle(in: shapeRect))
    }

    func insertEllipse() {
        insertShape(points: ShapeFactory.ellipse(in: shapeRect))
    }

    func insertArrow() {
        insertShape(points: ShapeFactory.arrow(in: shapeRect))
    }

    func exportPNG() -> URL? {
        guard let canvasView else { return nil }
        let image = canvasView.drawing.image(from: exportRect, scale: 2)
        guard let data = image.pngData() else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("massive-canvas.png")
        try? data.write(to: url, options: .atomic)
        return url
    }

    func exportPDF() -> URL? {
        let rect = exportRect
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: rect.size))
        let data = renderer.pdfData { context in
            context.beginPage()
            let image = canvasView?.drawing.image(from: rect, scale: 1) ?? UIImage()
            image.draw(in: CGRect(origin: .zero, size: rect.size))
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("massive-canvas.pdf")
        try? data.write(to: url, options: .atomic)
        return url
    }

    private func insertShape(points: [CGPoint]) {
        guard let canvasView, !points.isEmpty else { return }
        let strokePoints = points.enumerated().map { index, point in
            PKStrokePoint(
                location: point,
                timeOffset: TimeInterval(index) * 0.01,
                size: CGSize(width: 6, height: 6),
                opacity: 1,
                force: 1,
                azimuth: 0,
                altitude: .pi / 2
            )
        }
        let strokePath = PKStrokePath(controlPoints: strokePoints, creationDate: Date())
        let stroke = PKStroke(ink: PKInk(.pen, color: .systemBlue), path: strokePath)
        let drawing = canvasView.drawing.appending(PKDrawing(strokes: [stroke]))
        canvasView.drawing = drawing
        onDrawingChange?(drawing)
    }

    private var shapeRect: CGRect {
        guard let canvasView else { return CGRect(x: 19_500, y: 19_500, width: 300, height: 200) }
        let visible = CGRect(origin: canvasView.contentOffset, size: canvasView.bounds.size)
        let width = min(visible.width * 0.45, 320)
        let height = min(visible.height * 0.3, 220)
        return CGRect(x: visible.midX - width / 2, y: visible.midY - height / 2, width: width, height: height)
    }

    private var exportRect: CGRect {
        guard let canvasView else { return CGRect(x: 19_400, y: 19_500, width: 1_200, height: 800) }
        let bounds = canvasView.drawing.bounds
        if bounds.isNull || bounds.isEmpty {
            let visible = CGRect(origin: canvasView.contentOffset, size: canvasView.bounds.size)
            return visible.insetBy(dx: -40, dy: -40)
        }
        return bounds.insetBy(dx: -40, dy: -40)
    }
}

enum ShapeFactory {
    static func rectangle(in rect: CGRect) -> [CGPoint] {
        [
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.minY),
        ]
    }

    static func ellipse(in rect: CGRect, segments: Int = 48) -> [CGPoint] {
        guard segments > 2 else { return [] }
        return (0...segments).map { index in
            let angle = CGFloat(index) / CGFloat(segments) * .pi * 2
            return CGPoint(
                x: rect.midX + cos(angle) * rect.width / 2,
                y: rect.midY + sin(angle) * rect.height / 2
            )
        }
    }

    static func arrow(in rect: CGRect) -> [CGPoint] {
        let start = CGPoint(x: rect.minX, y: rect.midY)
        let end = CGPoint(x: rect.maxX, y: rect.midY)
        let head = min(rect.width * 0.22, 50)
        return [
            start,
            end,
            CGPoint(x: end.x - head, y: end.y - head * 0.7),
            end,
            CGPoint(x: end.x - head, y: end.y + head * 0.7),
        ]
    }
}

struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    var backgroundColor: UIColor = .secondarySystemBackground
    var drawingPolicy: PKCanvasViewDrawingPolicy = .anyInput
    var isOpaque: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.drawing = drawing
        canvasView.drawingPolicy = drawingPolicy
        canvasView.backgroundColor = backgroundColor
        canvasView.isOpaque = isOpaque
        canvasView.alwaysBounceVertical = true
        canvasView.alwaysBounceHorizontal = true
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing.dataRepresentation() != drawing.dataRepresentation() {
            uiView.drawing = drawing
        }

        uiView.drawingPolicy = drawingPolicy
        uiView.backgroundColor = backgroundColor
        uiView.isOpaque = isOpaque
        context.coordinator.activateToolPickerIfNeeded(for: uiView)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilCanvasView
        private let toolPicker = PKToolPicker()
        private var isToolPickerAttached = false

        init(_ parent: PencilCanvasView) {
            self.parent = parent
        }

        func activateToolPickerIfNeeded(for canvasView: PKCanvasView) {
            guard canvasView.window != nil else { return }

            if !isToolPickerAttached {
                toolPicker.addObserver(canvasView)
                isToolPickerAttached = true
            }

            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}

struct MassivePencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var controller: MassiveCanvasController?
    var canvasSize = CGSize(width: 40_000, height: 40_000)
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIView(context: Context) -> HostView {
        let view = HostView()
        view.delegate = context.coordinator
        view.drawing = drawing
        view.drawingPolicy = .anyInput
        view.backgroundColor = UIColor(patternImage: Self.grid())
        view.contentSize = canvasSize
        view.maximumZoomScale = 4
        view.bouncesZoom = true
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = true
        controller?.canvasView = view
        controller?.onDrawingChange = { context.coordinator.parent.drawing = $0 }
        return view
    }
    func updateUIView(_ uiView: HostView, context: Context) {
        if uiView.drawing.dataRepresentation() != drawing.dataRepresentation() { uiView.drawing = drawing }
        uiView.contentSize = canvasSize
        uiView.updateMinimumZoomScale()
        controller?.canvasView = uiView
        controller?.onDrawingChange = { context.coordinator.parent.drawing = $0 }
        context.coordinator.activateToolPickerIfNeeded(for: uiView)
    }
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: MassivePencilCanvasView
        private let picker = PKToolPicker()
        private var attached = false
        init(_ parent: MassivePencilCanvasView) { self.parent = parent }
        func activateToolPickerIfNeeded(for canvasView: PKCanvasView) {
            guard canvasView.window != nil else { return }
            if !attached { picker.addObserver(canvasView); attached = true }
            picker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) { parent.drawing = canvasView.drawing }
    }
    final class HostView: PKCanvasView {
        private var centered = false
        override func layoutSubviews() {
            super.layoutSubviews()
            updateMinimumZoomScale()
            guard !centered, bounds.width > 0, bounds.height > 0 else { return }
            setContentOffset(CGPoint(x: max((contentSize.width - bounds.width) / 2, 0), y: max((contentSize.height - bounds.height) / 2, 0)), animated: false)
            centered = true
        }
        func updateMinimumZoomScale() {
            guard bounds.width > 0, bounds.height > 0, contentSize.width > 0, contentSize.height > 0 else { return }
            minimumZoomScale = min(bounds.width / contentSize.width, bounds.height / contentSize.height)
        }
    }
    static func grid(step: CGFloat = 40) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default(); format.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: step, height: step), format: format).image { ctx in
            UIColor.systemBackground.setFill(); ctx.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: step, height: step)))
            ctx.cgContext.setStrokeColor(UIColor.systemGray5.cgColor); ctx.cgContext.setLineWidth(1)
            ctx.cgContext.move(to: CGPoint(x: step, y: 0)); ctx.cgContext.addLine(to: CGPoint(x: step, y: step))
            ctx.cgContext.move(to: CGPoint(x: 0, y: step)); ctx.cgContext.addLine(to: CGPoint(x: step, y: step)); ctx.cgContext.strokePath()
        }
    }
}
