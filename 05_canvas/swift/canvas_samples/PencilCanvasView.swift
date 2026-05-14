//
//  PencilCanvasView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import PencilKit
import SwiftUI

enum MassiveCanvasMode: String, CaseIterable, Identifiable {
    case draw
    case edit

    var id: Self { self }
}

enum MassiveShapeKind {
    case rectangle
    case ellipse
    case arrow
}

struct MassiveShapeItem: Identifiable, Equatable {
    let id: UUID
    var kind: MassiveShapeKind
    var frame: CGRect
}

private enum ResizeHandle {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

@MainActor
final class MassiveCanvasController: ObservableObject {
    weak var canvasView: PKCanvasView?
    @Published var mode: MassiveCanvasMode = .draw
    @Published var items: [MassiveShapeItem] = []
    @Published var selectedItemID: UUID?

    func insertRectangle() {
        insertItem(kind: .rectangle)
    }

    func insertEllipse() {
        insertItem(kind: .ellipse)
    }

    func insertArrow() {
        insertItem(kind: .arrow)
    }

    func exportPNG() -> URL? {
        let data = MassiveShapeRenderer.pngData(
            drawing: canvasView?.drawing ?? PKDrawing(),
            items: items,
            rect: exportRect
        )
        guard let data else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("massive-canvas.png")
        try? data.write(to: url, options: .atomic)
        return url
    }

    func exportPDF() -> URL? {
        let data = MassiveShapeRenderer.pdfData(
            drawing: canvasView?.drawing ?? PKDrawing(),
            items: items,
            rect: exportRect
        )
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("massive-canvas.pdf")
        try? data.write(to: url, options: .atomic)
        return url
    }

    private func insertItem(kind: MassiveShapeKind) {
        let item = MassiveShapeItem(id: UUID(), kind: kind, frame: shapeRect)
        items.append(item)
        selectedItemID = item.id
        mode = .edit
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
        var rect = canvasView.drawing.bounds
        for item in items {
            rect = rect.isNull ? item.frame : rect.union(item.frame)
        }
        if rect.isNull || rect.isEmpty {
            let visible = CGRect(origin: canvasView.contentOffset, size: canvasView.bounds.size)
            return visible.insetBy(dx: -40, dy: -40)
        }
        return rect.insetBy(dx: -40, dy: -40)
    }
}

private enum MassiveShapeRenderer {
    static func pngData(drawing: PKDrawing, items: [MassiveShapeItem], rect: CGRect) -> Data? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 2
        format.opaque = true
        let image = UIGraphicsImageRenderer(size: rect.size, format: format).image { context in
            UIColor.systemBackground.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: rect.size))
            drawing.image(from: rect, scale: 1).draw(in: CGRect(origin: .zero, size: rect.size))
            draw(items: items, offset: rect.origin, zoomScale: 1, selectedItemID: nil, in: context.cgContext)
        }
        return image.pngData()
    }

    static func pdfData(drawing: PKDrawing, items: [MassiveShapeItem], rect: CGRect) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: rect.size))
        return renderer.pdfData { context in
            context.beginPage()
            UIColor.systemBackground.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: rect.size))
            drawing.image(from: rect, scale: 1).draw(in: CGRect(origin: .zero, size: rect.size))
            draw(items: items, offset: rect.origin, zoomScale: 1, selectedItemID: nil, in: context.cgContext)
        }
    }

    static func draw(
        items: [MassiveShapeItem],
        offset: CGPoint,
        zoomScale: CGFloat,
        selectedItemID: UUID?,
        in context: CGContext
    ) {
        for item in items {
            draw(item: item, offset: offset, zoomScale: zoomScale)
        }

        guard let selectedItemID, let selectedItem = items.first(where: { $0.id == selectedItemID }) else { return }
        let visibleFrame = selectedItem.frame.offsetBy(dx: -offset.x, dy: -offset.y)
        let outline = UIBezierPath(rect: visibleFrame)
        outline.lineWidth = max(2 / max(zoomScale, 0.25), 1)
        outline.setLineDash([8 / max(zoomScale, 0.25), 6 / max(zoomScale, 0.25)], count: 2, phase: 0)
        UIColor.systemRed.setStroke()
        outline.stroke()

        for handleFrame in handleFrames(for: selectedItem.frame, offset: offset, zoomScale: zoomScale).values {
            let handle = UIBezierPath(roundedRect: handleFrame, cornerRadius: handleFrame.width / 4)
            UIColor.systemBackground.setFill()
            UIColor.systemRed.setStroke()
            handle.lineWidth = max(2 / max(zoomScale, 0.25), 1)
            handle.fill()
            handle.stroke()
        }
    }

    static func handleFrames(for frame: CGRect, offset: CGPoint, zoomScale: CGFloat) -> [ResizeHandle: CGRect] {
        let visible = frame.offsetBy(dx: -offset.x, dy: -offset.y)
        let size = max(14 / max(zoomScale, 0.25), 8)
        let half = size / 2
        return [
            .topLeading: CGRect(x: visible.minX - half, y: visible.minY - half, width: size, height: size),
            .topTrailing: CGRect(x: visible.maxX - half, y: visible.minY - half, width: size, height: size),
            .bottomLeading: CGRect(x: visible.minX - half, y: visible.maxY - half, width: size, height: size),
            .bottomTrailing: CGRect(x: visible.maxX - half, y: visible.maxY - half, width: size, height: size),
        ]
    }

    private static func draw(item: MassiveShapeItem, offset: CGPoint, zoomScale: CGFloat) {
        let frame = item.frame.offsetBy(dx: -offset.x, dy: -offset.y)
        switch item.kind {
        case .rectangle:
            let path = UIBezierPath(rect: frame)
            UIColor.systemBlue.withAlphaComponent(0.12).setFill()
            UIColor.systemBlue.setStroke()
            path.lineWidth = max(3 / max(zoomScale, 0.25), 1.5)
            path.fill()
            path.stroke()
        case .ellipse:
            let path = UIBezierPath(ovalIn: frame)
            UIColor.systemGreen.withAlphaComponent(0.12).setFill()
            UIColor.systemGreen.setStroke()
            path.lineWidth = max(3 / max(zoomScale, 0.25), 1.5)
            path.fill()
            path.stroke()
        case .arrow:
            let start = CGPoint(x: frame.minX, y: frame.midY)
            let end = CGPoint(x: frame.maxX, y: frame.midY)
            let line = UIBezierPath()
            line.move(to: start)
            line.addLine(to: end)
            line.lineWidth = max(4 / max(zoomScale, 0.25), 2)
            line.lineCapStyle = .round
            UIColor.systemOrange.setStroke()
            line.stroke()

            let head = min(frame.width * 0.22, 50 / max(zoomScale, 0.25))
            let headPath = UIBezierPath()
            headPath.move(to: end)
            headPath.addLine(to: CGPoint(x: end.x - head, y: end.y - head * 0.7))
            headPath.move(to: end)
            headPath.addLine(to: CGPoint(x: end.x - head, y: end.y + head * 0.7))
            headPath.lineWidth = max(4 / max(zoomScale, 0.25), 2)
            headPath.lineCapStyle = .round
            UIColor.systemOrange.setStroke()
            headPath.stroke()
        }
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
    @ObservedObject var controller: MassiveCanvasController

    var canvasSize = CGSize(width: 40_000, height: 40_000)

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> HostView {
        let view = HostView()
        view.canvasView.delegate = context.coordinator
        view.configure(canvasSize: canvasSize)
        view.overlayView.onItemsChanged = { items, selectedItemID in
            context.coordinator.parent.controller.items = items
            context.coordinator.parent.controller.selectedItemID = selectedItemID
        }
        controller.canvasView = view.canvasView
        return view
    }

    func updateUIView(_ uiView: HostView, context: Context) {
        if uiView.canvasView.drawing.dataRepresentation() != drawing.dataRepresentation() {
            uiView.canvasView.drawing = drawing
        }

        uiView.configure(canvasSize: canvasSize)
        uiView.overlayView.items = controller.items
        uiView.overlayView.selectedItemID = controller.selectedItemID
        uiView.overlayView.mode = controller.mode
        controller.canvasView = uiView.canvasView
        uiView.canvasView.drawingGestureRecognizer.isEnabled = controller.mode == .draw
        context.coordinator.activateToolPickerIfNeeded(for: uiView.canvasView, isDrawingMode: controller.mode == .draw)
        uiView.syncOverlay()
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: MassivePencilCanvasView
        private let toolPicker = PKToolPicker()
        private var attached = false

        init(_ parent: MassivePencilCanvasView) {
            self.parent = parent
        }

        func activateToolPickerIfNeeded(for canvasView: PKCanvasView, isDrawingMode: Bool) {
            guard canvasView.window != nil else { return }
            if !attached {
                toolPicker.addObserver(canvasView)
                attached = true
            }
            toolPicker.setVisible(isDrawingMode, forFirstResponder: canvasView)
            if isDrawingMode {
                canvasView.becomeFirstResponder()
            } else {
                canvasView.resignFirstResponder()
            }
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            (scrollView.superview as? HostView)?.syncOverlay()
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            (scrollView.superview as? HostView)?.syncOverlay()
        }
    }

    final class HostView: UIView {
        let canvasView = PKCanvasView()
        let overlayView = MassiveShapeOverlayView()

        private var centered = false
        private var currentCanvasSize = CGSize.zero

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            canvasView.drawingPolicy = .anyInput
            canvasView.backgroundColor = UIColor(patternImage: MassivePencilCanvasView.grid())
            canvasView.maximumZoomScale = 4
            canvasView.bouncesZoom = true
            canvasView.alwaysBounceVertical = true
            canvasView.alwaysBounceHorizontal = true
            canvasView.showsVerticalScrollIndicator = true
            canvasView.showsHorizontalScrollIndicator = true
            addSubview(canvasView)
            addSubview(overlayView)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            canvasView.frame = bounds
            overlayView.frame = bounds
            updateMinimumZoomScale()
            guard !centered, bounds.width > 0, bounds.height > 0 else {
                syncOverlay()
                return
            }
            canvasView.setContentOffset(
                CGPoint(
                    x: max((currentCanvasSize.width - bounds.width) / 2, 0),
                    y: max((currentCanvasSize.height - bounds.height) / 2, 0)
                ),
                animated: false
            )
            centered = true
            syncOverlay()
        }

        func configure(canvasSize: CGSize) {
            guard currentCanvasSize != canvasSize else { return }
            currentCanvasSize = canvasSize
            canvasView.contentSize = canvasSize
            centered = false
            setNeedsLayout()
        }

        func syncOverlay() {
            overlayView.contentOffset = canvasView.contentOffset
            overlayView.zoomScale = canvasView.zoomScale
            overlayView.setNeedsDisplay()
        }

        private func updateMinimumZoomScale() {
            guard bounds.width > 0, bounds.height > 0, currentCanvasSize.width > 0, currentCanvasSize.height > 0 else { return }
            canvasView.minimumZoomScale = min(bounds.width / currentCanvasSize.width, bounds.height / currentCanvasSize.height)
        }
    }

    static func grid(step: CGFloat = 40) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true

        return UIGraphicsImageRenderer(size: CGSize(width: step, height: step), format: format).image { ctx in
            UIColor.systemBackground.setFill()
            ctx.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: step, height: step)))
            ctx.cgContext.setStrokeColor(UIColor.systemGray5.cgColor)
            ctx.cgContext.setLineWidth(1)
            ctx.cgContext.move(to: CGPoint(x: step, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: step, y: step))
            ctx.cgContext.move(to: CGPoint(x: 0, y: step))
            ctx.cgContext.addLine(to: CGPoint(x: step, y: step))
            ctx.cgContext.strokePath()
        }
    }
}

private final class MassiveShapeOverlayView: UIView, UIGestureRecognizerDelegate {
    var items: [MassiveShapeItem] = [] { didSet { setNeedsDisplay() } }
    var selectedItemID: UUID? { didSet { setNeedsDisplay() } }
    var mode: MassiveCanvasMode = .draw { didSet { updateInteraction() } }
    var contentOffset: CGPoint = .zero
    var zoomScale: CGFloat = 1
    var onItemsChanged: (([MassiveShapeItem], UUID?) -> Void)?

    private enum Interaction {
        case move(id: UUID, startPoint: CGPoint, startFrame: CGRect)
        case resize(id: UUID, handle: ResizeHandle, startPoint: CGPoint, startFrame: CGRect)
    }

    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    private var interaction: Interaction?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        tapGesture.delegate = self
        panGesture.delegate = self
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(panGesture)
        updateInteraction()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        MassiveShapeRenderer.draw(
            items: items,
            offset: contentOffset,
            zoomScale: zoomScale,
            selectedItemID: selectedItemID,
            in: context
        )
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard mode == .edit else { return false }
        let point = touch.location(in: self)
        if gestureRecognizer == panGesture {
            return resizeHandle(at: point) != nil || item(at: point) != nil
        }
        return true
    }

    private func updateInteraction() {
        let enabled = mode == .edit
        isUserInteractionEnabled = enabled
        tapGesture.isEnabled = enabled
        panGesture.isEnabled = enabled
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        selectedItemID = item(at: recognizer.location(in: self))?.id
        onItemsChanged?(items, selectedItemID)
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self)
        let boardPoint = boardPoint(from: point)

        switch recognizer.state {
        case .began:
            if let handle = resizeHandle(at: point), let selectedItem {
                interaction = .resize(id: selectedItem.id, handle: handle, startPoint: boardPoint, startFrame: selectedItem.frame)
            } else if let item = item(at: point) {
                selectedItemID = item.id
                interaction = .move(id: item.id, startPoint: boardPoint, startFrame: item.frame)
                onItemsChanged?(items, selectedItemID)
            }
        case .changed:
            guard let interaction, let index = items.firstIndex(where: { $0.id == interaction.id }) else { return }
            let delta = CGPoint(x: boardPoint.x - interaction.startPoint.x, y: boardPoint.y - interaction.startPoint.y)
            switch interaction {
            case let .move(_, _, startFrame):
                items[index].frame = startFrame.offsetBy(dx: delta.x, dy: delta.y)
            case let .resize(_, handle, _, startFrame):
                items[index].frame = resizedFrame(from: startFrame, delta: delta, handle: handle)
            }
            selectedItemID = items[index].id
            onItemsChanged?(items, selectedItemID)
            setNeedsDisplay()
        default:
            interaction = nil
        }
    }

    private var selectedItem: MassiveShapeItem? {
        guard let selectedItemID else { return nil }
        return items.first(where: { $0.id == selectedItemID })
    }

    private func item(at point: CGPoint) -> MassiveShapeItem? {
        let boardPoint = boardPoint(from: point)
        return items.reversed().first { item in
            item.frame.insetBy(dx: -12 / max(zoomScale, 0.25), dy: -12 / max(zoomScale, 0.25)).contains(boardPoint)
        }
    }

    private func resizeHandle(at point: CGPoint) -> ResizeHandle? {
        guard let selectedItem else { return nil }
        return MassiveShapeRenderer.handleFrames(for: selectedItem.frame, offset: contentOffset, zoomScale: zoomScale)
            .first(where: { $0.value.contains(point) })?
            .key
    }

    private func boardPoint(from point: CGPoint) -> CGPoint {
        CGPoint(
            x: point.x / max(zoomScale, 0.25) + contentOffset.x,
            y: point.y / max(zoomScale, 0.25) + contentOffset.y
        )
    }

    private func resizedFrame(from frame: CGRect, delta: CGPoint, handle: ResizeHandle) -> CGRect {
        let minWidth: CGFloat = 120
        let minHeight: CGFloat = 80
        var rect = frame

        switch handle {
        case .topLeading:
            rect.origin.x += delta.x
            rect.origin.y += delta.y
            rect.size.width -= delta.x
            rect.size.height -= delta.y
        case .topTrailing:
            rect.origin.y += delta.y
            rect.size.width += delta.x
            rect.size.height -= delta.y
        case .bottomLeading:
            rect.origin.x += delta.x
            rect.size.width -= delta.x
            rect.size.height += delta.y
        case .bottomTrailing:
            rect.size.width += delta.x
            rect.size.height += delta.y
        }

        if rect.width < minWidth {
            if handle == .topLeading || handle == .bottomLeading {
                rect.origin.x = frame.maxX - minWidth
            }
            rect.size.width = minWidth
        }

        if rect.height < minHeight {
            if handle == .topLeading || handle == .topTrailing {
                rect.origin.y = frame.maxY - minHeight
            }
            rect.size.height = minHeight
        }

        return rect.standardized
    }
}

private extension MassiveShapeOverlayView.Interaction {
    var id: UUID {
        switch self {
        case let .move(id, _, _), let .resize(id, _, _, _):
            id
        }
    }

    var startPoint: CGPoint {
        switch self {
        case let .move(_, startPoint, _), let .resize(_, _, startPoint, _):
            startPoint
        }
    }
}
