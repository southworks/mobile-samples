//
//  canvas_samplesTests.swift
//  canvas_samplesTests
//
//  Created by ec2-user on 5/12/26.
//

import Foundation
import Testing
@testable import canvas_samples

struct canvas_samplesTests {

    @Test func boardDocumentPayloadRoundTripPreservesItems() throws {
        let source = BoardItem.makeShape(kind: .rectangle, centeredAt: CGPoint(x: 100, y: 120), zIndex: 1)
        let target = BoardItem.makeShape(kind: .ellipse, centeredAt: CGPoint(x: 420, y: 360), zIndex: 2)
        let anchors = BoardGeometry.bestAnchors(from: source, to: target)
        let arrow = BoardItem.makeArrow(source: source, target: target, anchors: anchors, zIndex: 3)
        let payload = BoardDocumentPayload(items: [source, target, arrow])

        let data = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(BoardDocumentPayload.self, from: data)

        #expect(decoded.items.count == 3)
        #expect(decoded.items.last?.sourceItemID == source.id)
        #expect(decoded.items.last?.targetItemID == target.id)
    }

    @Test func bestAnchorsReturnValidConnectorEndpoints() {
        let source = BoardItem.makeShape(kind: .rectangle, centeredAt: CGPoint(x: 100, y: 100), zIndex: 1)
        let target = BoardItem.makeShape(kind: .roundedRectangle, centeredAt: CGPoint(x: 500, y: 100), zIndex: 2)
        let anchors = BoardGeometry.bestAnchors(from: source, to: target)
        let arrow = BoardItem.makeArrow(source: source, target: target, anchors: anchors, zIndex: 3)
        let lookup = [source.id: source, target.id: target]
        let endpoints = BoardGeometry.arrowEndpoints(for: arrow, itemsByID: lookup)

        #expect(endpoints != nil)
        #expect(anchors.0 == .trailing || anchors.0 == .top || anchors.0 == .bottom)
        #expect(anchors.1 == .leading || anchors.1 == .top || anchors.1 == .bottom)
    }

}
