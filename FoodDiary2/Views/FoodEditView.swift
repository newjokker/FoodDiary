//
//  FoodEditView.swift
//  FoodDiary2
//
//  Created by jo k ke r 凌 on 2025/2/5.
//

import SwiftUI
import SwiftData

struct FoodEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var category: FoodCategory
    
    @State private var showingAddFood = false
    @State private var newFoodName = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(category.foods, id: \.self) { food in
                    Text(food)
                }
                .onDelete(perform: deleteFoods)
            }
            .navigationTitle("\(category.type) 食物列表")
            .navigationBarItems(
                leading: Button("完成") { dismiss() },
                trailing: Button(action: { showingAddFood = true }) {
                    Image(systemName: "plus")
                }
            )
            .alert("添加新食物", isPresented: $showingAddFood) {
                TextField("食物名称", text: $newFoodName)
                Button("取消", role: .cancel) { }
                Button("添加") { addFood() }
            }
        }
    }
    
    private func addFood() {
        guard !newFoodName.isEmpty else { return }
        category.foods.append(newFoodName)
        newFoodName = ""
    }
    
    private func deleteFoods(at offsets: IndexSet) {
        category.foods.remove(atOffsets: offsets)
    }
}
