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

    var canvasSize: CGSize = CGSize(width: 20_000, height: 20_000)

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> InfiniteCanvasHostingView {
        let canvasView = InfiniteCanvasHostingView()
        canvasView.delegate = context.coordinator
        canvasView.drawing = drawing
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = UIColor(patternImage: GridPattern.make())
        canvasView.contentSize = canvasSize
        canvasView.minimumZoomScale = 0.2
        canvasView.maximumZoomScale = 4
        canvasView.bouncesZoom = true
        canvasView.alwaysBounceVertical = true
        canvasView.alwaysBounceHorizontal = true
        canvasView.showsVerticalScrollIndicator = true
        canvasView.showsHorizontalScrollIndicator = true
        return canvasView
    }

    func updateUIView(_ uiView: InfiniteCanvasHostingView, context: Context) {
        if uiView.drawing.dataRepresentation() != drawing.dataRepresentation() {
            uiView.drawing = drawing
        }

        uiView.contentSize = canvasSize
        context.coordinator.activateToolPickerIfNeeded(for: uiView)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: InfinitePencilCanvasView
        private let toolPicker = PKToolPicker()
        private var isToolPickerAttached = false

        init(_ parent: InfinitePencilCanvasView) {
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

final class InfiniteCanvasHostingView: PKCanvasView {
    private var didCenterInitialViewport = false

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !didCenterInitialViewport, bounds.width > 0, bounds.height > 0 else { return }

        // Start in the middle so the user can move in every direction.
        let centeredOffset = CGPoint(
            x: max((contentSize.width - bounds.width) / 2, 0),
            y: max((contentSize.height - bounds.height) / 2, 0)
        )

        setContentOffset(centeredOffset, animated: false)
        didCenterInitialViewport = true
    }
}

enum GridPattern {
    static func make(step: CGFloat = 40) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true

        return UIGraphicsImageRenderer(size: CGSize(width: step, height: step), format: format).image { context in
            let cgContext = context.cgContext
            UIColor.systemBackground.setFill()
            cgContext.fill(CGRect(origin: .zero, size: CGSize(width: step, height: step)))

            cgContext.setStrokeColor(UIColor.systemGray5.cgColor)
            cgContext.setLineWidth(1)

            cgContext.move(to: CGPoint(x: step, y: 0))
            cgContext.addLine(to: CGPoint(x: step, y: step))
            cgContext.move(to: CGPoint(x: 0, y: step))
            cgContext.addLine(to: CGPoint(x: step, y: step))
            cgContext.strokePath()
        }
    }
}
