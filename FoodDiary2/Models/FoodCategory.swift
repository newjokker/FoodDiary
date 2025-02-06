//
//  FoodCategory.swift
//  FoodDiary2
//
//  Created by jo k ke r 凌 on 2025/2/5.
//

import SwiftData
import Foundation


/// 食物类别数据模型
@Model
class FoodCategory {
    var type: String
    var foods: [String]
    var index: Int
    
    init(type: String, foods: [String], index: Int=0) {
        self.type = type
        self.foods = foods
        self.index = index
    }
}

