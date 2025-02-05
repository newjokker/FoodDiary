//
//  FoodEntry.swift
//  FoodDiary2
//
//  Created by jo k ke r 凌 on 2025/2/5.
//

import SwiftData
import Foundation

/// 记录用户“吃了什么”的历史条目
@Model
class FoodEntry {
    var type: String
    var name: String
    var date: Date
    
    init(type: String, name: String, date: Date) {
        self.type = type
        self.name = name
        self.date = date
    }
}
