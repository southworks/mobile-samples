//
//  Item.swift
//  calendar_and_events
//
//  Created by ec2-user on 5/22/26.
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
