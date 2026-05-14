//
//  MassiveBoardView.swift
//  canvas_samples
//
//  Created by Codex on 5/14/26.
//

import PencilKit
import SwiftUI

struct MassiveBoardView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var items: [BoardItem]
    @Binding var mode: BoardInteractionMode
    @Binding var selectedItemID: UUID?
    @Binding var pendingArrowSourceID: UUID?

    var canvasSize = CGSize(width: 40_000, height: 40_000)
    var onRequestTextEdit: (UUID) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> HostView {
        let view = HostView()
        view.canvasView.delegate = context.coordinator
        view.overlayView.onItemsChanged = { context.coordinator.parent.items = $0 }
        view.overlayView.onSelectionChanged = { context.coordinator.parent.selectedItemID = $0 }
        view.overlayView.onPendingArrowSourceChanged = { context.coordinator.parent.pendingArrowSourceID = $0 }
        view.overlayView.onRequestTextEdit = onRequestTextEdit
        view.configure(canvasSize: canvasSize)
        return view
    }

    func updateUIView(_ uiView: HostView, context: Context) {
        context.coordinator.parent = self
        uiView.configure(canvasSize: canvasSize)

        if uiView.canvasView.drawing.dataRepresentation() != drawing.dataRepresentation() {
            uiView.canvasView.drawing = drawing
        }

        uiView.overlayView.items = items
        uiView.overlayView.mode = mode
        uiView.overlayView.selectedItemID = selectedItemID
        uiView.overlayView.pendingArrowSourceID = pendingArrowSourceID
        uiView.overlayView.onRequestTextEdit = onRequestTextEdit
        uiView.canvasView.drawingGestureRecognizer.isEnabled = mode == .draw
        context.coordinator.updateToolPicker(for: uiView.canvasView, isDrawingMode: mode == .draw)
        uiView.syncOverlay()
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: MassiveBoardView
        private let toolPicker = PKToolPicker()
        private var isAttached = false

        init(parent: MassiveBoardView) {
            self.parent = parent
        }

        func updateToolPicker(for canvasView: PKCanvasView, isDrawingMode: Bool) {
            guard canvasView.window != nil else { return }

            if !isAttached {
                toolPicker.addObserver(canvasView)
                isAttached = true
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
        let overlayView = BoardOverlayView()

        private var didCenterInitialViewport = false
        private var currentCanvasSize = CGSize.zero

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            canvasView.backgroundColor = UIColor(patternImage: MassivePencilCanvasView.grid())
            canvasView.drawingPolicy = .anyInput
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
            if !didCenterInitialViewport, bounds.width > 0, bounds.height > 0 {
                let centeredOffset = CGPoint(
                    x: max((canvasView.contentSize.width - bounds.width) / 2, 0),
                    y: max((canvasView.contentSize.height - bounds.height) / 2, 0)
                )
                canvasView.setContentOffset(centeredOffset, animated: false)
                didCenterInitialViewport = true
            }
            syncOverlay()
        }

        func configure(canvasSize: CGSize) {
            guard currentCanvasSize != canvasSize else { return }
            currentCanvasSize = canvasSize
            canvasView.contentSize = canvasSize
            overlayView.contentSize = canvasSize
            didCenterInitialViewport = false
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
}

private final class BoardOverlayView: UIView, UIGestureRecognizerDelegate {
    var items: [BoardItem] = [] { didSet { setNeedsDisplay() } }
    var mode: BoardInteractionMode = .draw { didSet { updateGestureAvailability() } }
    var selectedItemID: UUID? { didSet { setNeedsDisplay() } }
    var pendingArrowSourceID: UUID? { didSet { setNeedsDisplay() } }
    var contentOffset: CGPoint = .zero
    var zoomScale: CGFloat = 1
    var contentSize: CGSize = .zero

    var onItemsChanged: (([BoardItem]) -> Void)?
    var onSelectionChanged: ((UUID?) -> Void)?
    var onPendingArrowSourceChanged: ((UUID?) -> Void)?
    var onRequestTextEdit: ((UUID) -> Void)?

    private enum Interaction {
        case drag(id: UUID, startFrame: CGRect, startPoint: CGPoint)
        case resize(id: UUID, handle: ResizeHandle, startFrame: CGRect, startPoint: CGPoint)
    }

    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    private lazy var panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    private var interaction: Interaction?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        tapRecognizer.delegate = self
        panRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(panRecognizer)
        updateGestureAvailability()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.concatenate(CGAffineTransform(
            a: zoomScale,
            b: 0,
            c: 0,
            d: zoomScale,
            tx: -contentOffset.x * zoomScale,
            ty: -contentOffset.y * zoomScale
        ))
        BoardSceneRenderer.draw(
            items: items,
            selectedItemID: selectedItemID,
            pendingArrowSourceID: pendingArrowSourceID,
            in: context,
            zoomScale: zoomScale
        )
        context.restoreGState()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard mode == .select else { return gestureRecognizer == tapRecognizer && mode != .draw }
        let boardPoint = boardPoint(fromViewPoint: touch.location(in: self))
        if gestureRecognizer == panRecognizer {
            return resizeHandle(at: boardPoint) != nil || item(at: boardPoint) != nil
        }
        return true
    }

    private func updateGestureAvailability() {
        let isDrawing = mode == .draw
        isUserInteractionEnabled = !isDrawing
        tapRecognizer.isEnabled = !isDrawing
        panRecognizer.isEnabled = mode == .select
        setNeedsDisplay()
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        let boardPoint = boardPoint(fromViewPoint: recognizer.location(in: self))

        switch mode {
        case .select:
            let tappedItem = item(at: boardPoint)
            selectedItemID = tappedItem?.id
            onSelectionChanged?(tappedItem?.id)
            onPendingArrowSourceChanged?(nil)
            pendingArrowSourceID = nil
            if tappedItem?.isTextEditable == true, let id = tappedItem?.id {
                onRequestTextEdit?(id)
            }
        case .draw:
            break
        case .text:
            var updatedItems = items
            let newItem = BoardItem.makeText(centeredAt: boardPoint, zIndex: nextZIndex)
            updatedItems.append(newItem)
            apply(items: updatedItems, selectedItemID: newItem.id)
            onRequestTextEdit?(newItem.id)
        case .arrow:
            guard let target = item(at: boardPoint), target.isConnectable else { return }

            if let pendingArrowSourceID, let source = items.first(where: { $0.id == pendingArrowSourceID }), source.id != target.id {
                var updatedItems = items
                let anchors = BoardGeometry.bestAnchors(from: source, to: target)
                let arrow = BoardItem.makeArrow(source: source, target: target, anchors: anchors, zIndex: nextZIndex)
                updatedItems.append(arrow)
                pendingArrowSourceID = nil
                onPendingArrowSourceChanged?(nil)
                apply(items: updatedItems, selectedItemID: arrow.id)
            } else {
                pendingArrowSourceID = target.id
                onPendingArrowSourceChanged?(target.id)
                selectedItemID = target.id
                onSelectionChanged?(target.id)
                setNeedsDisplay()
            }
        case .rectangle, .roundedRectangle, .ellipse:
            let kind: BoardItemKind = switch mode {
            case .rectangle: .rectangle
            case .roundedRectangle: .roundedRectangle
            case .ellipse: .ellipse
            default: .rectangle
            }
            var updatedItems = items
            let newItem = BoardItem.makeShape(kind: kind, centeredAt: boardPoint, zIndex: nextZIndex)
            updatedItems.append(newItem)
            apply(items: updatedItems, selectedItemID: newItem.id)
        }
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let boardPoint = boardPoint(fromViewPoint: recognizer.location(in: self))

        switch recognizer.state {
        case .began:
            if let handle = resizeHandle(at: boardPoint), let selected = selectedItem, selected.isResizable {
                interaction = .resize(id: selected.id, handle: handle, startFrame: selected.frame, startPoint: boardPoint)
            } else if let item = item(at: boardPoint), item.kind != .arrow {
                selectedItemID = item.id
                onSelectionChanged?(item.id)
                interaction = .drag(id: item.id, startFrame: item.frame, startPoint: boardPoint)
            } else if let arrow = item(at: boardPoint) {
                selectedItemID = arrow.id
                onSelectionChanged?(arrow.id)
            }
        case .changed:
            guard let interaction else { return }
            var updatedItems = items
            let delta = CGPoint(x: boardPoint.x - interaction.startPoint.x, y: boardPoint.y - interaction.startPoint.y)
            guard let index = updatedItems.firstIndex(where: { $0.id == interaction.itemID }) else { return }

            switch interaction {
            case let .drag(_, startFrame, _):
                updatedItems[index].frame = startFrame.offsetBy(dx: delta.x, dy: delta.y)
            case let .resize(_, handle, startFrame, _):
                updatedItems[index].frame = resizedFrame(from: startFrame, delta: delta, handle: handle, kind: updatedItems[index].kind)
            }

            apply(items: updatedItems, selectedItemID: updatedItems[index].id)
        default:
            interaction = nil
        }
    }

    private func apply(items: [BoardItem], selectedItemID: UUID?) {
        self.items = items
        self.selectedItemID = selectedItemID
        onItemsChanged?(items)
        onSelectionChanged?(selectedItemID)
        setNeedsDisplay()
    }

    private var nextZIndex: Double {
        (items.map(\.zIndex).max() ?? 0) + 1
    }

    private var selectedItem: BoardItem? {
        guard let selectedItemID else { return nil }
        return items.first(where: { $0.id == selectedItemID })
    }

    private func boardPoint(fromViewPoint point: CGPoint) -> CGPoint {
        CGPoint(x: point.x / max(zoomScale, 0.25) + contentOffset.x, y: point.y / max(zoomScale, 0.25) + contentOffset.y)
    }

    private func item(at point: CGPoint) -> BoardItem? {
        let lookup = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        return items.sorted { $0.zIndex < $1.zIndex }.reversed().first { item in
            if item.kind == .arrow, let (start, end) = BoardGeometry.arrowEndpoints(for: item, itemsByID: lookup) {
                return distance(from: point, to: start, and: end) < max(18 / max(zoomScale, 0.25), 10)
            }
            return item.frame.insetBy(dx: -10, dy: -10).contains(point)
        }
    }

    private func resizeHandle(at point: CGPoint) -> ResizeHandle? {
        guard let item = selectedItem, item.isResizable else { return nil }
        return BoardGeometry.selectionHandleFrames(for: item.frame, zoomScale: zoomScale).first { $0.value.contains(point) }?.key
    }

    private func resizedFrame(from frame: CGRect, delta: CGPoint, handle: ResizeHandle, kind: BoardItemKind) -> CGRect {
        let minWidth: CGFloat = kind == .text ? 180 : 120
        let minHeight: CGFloat = kind == .text ? 70 : 90
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

    private func distance(from point: CGPoint, to start: CGPoint, and end: CGPoint) -> CGFloat {
        let lengthSquared = pow(end.x - start.x, 2) + pow(end.y - start.y, 2)
        guard lengthSquared > 0 else { return hypot(point.x - start.x, point.y - start.y) }
        let projection = max(0, min(1, ((point.x - start.x) * (end.x - start.x) + (point.y - start.y) * (end.y - start.y)) / lengthSquared))
        let projectedPoint = CGPoint(x: start.x + projection * (end.x - start.x), y: start.y + projection * (end.y - start.y))
        return hypot(point.x - projectedPoint.x, point.y - projectedPoint.y)
    }
}

private extension BoardOverlayView.Interaction {
    var startPoint: CGPoint {
        switch self {
        case let .drag(_, _, startPoint), let .resize(_, _, _, startPoint):
            startPoint
        }
    }

    var itemID: UUID {
        switch self {
        case let .drag(id, _, _), let .resize(id, _, _, _):
            id
        }
    }
}
