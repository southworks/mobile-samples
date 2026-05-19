//
//  Item.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
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
