//
//  Item.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
