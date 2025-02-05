//
//  Item.swift
//  FoodDiary2
//
//  Created by jo k ke r 凌 on 2025/2/5.
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
