//
//  PencilCanvasView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import PencilKit
import SwiftUI

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

struct InfinitePencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var canvasSize = CGSize(width: 20_000, height: 20_000)
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIView(context: Context) -> HostView {
        let view = HostView()
        view.delegate = context.coordinator
        view.drawing = drawing
        view.drawingPolicy = .anyInput
        view.backgroundColor = UIColor(patternImage: Self.grid())
        view.contentSize = canvasSize
        view.minimumZoomScale = 0.2
        view.maximumZoomScale = 4
        view.bouncesZoom = true
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = true
        return view
    }
    func updateUIView(_ uiView: HostView, context: Context) {
        if uiView.drawing.dataRepresentation() != drawing.dataRepresentation() { uiView.drawing = drawing }
        uiView.contentSize = canvasSize
        context.coordinator.activateToolPickerIfNeeded(for: uiView)
    }
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: InfinitePencilCanvasView
        private let picker = PKToolPicker()
        private var attached = false
        init(_ parent: InfinitePencilCanvasView) { self.parent = parent }
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
            guard !centered, bounds.width > 0, bounds.height > 0 else { return }
            setContentOffset(CGPoint(x: max((contentSize.width - bounds.width) / 2, 0), y: max((contentSize.height - bounds.height) / 2, 0)), animated: false)
            centered = true
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
