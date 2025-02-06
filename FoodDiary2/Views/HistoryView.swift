//
//  HistoryView.swift
//  FoodDiary2
//
//  Created by jo k ke r 凌 on 2025/2/5.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var foodEntries: [FoodEntry] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodEntries) { entry in
                    HStack(spacing: 8) {
                        // 1. 类型
                        Text(entry.type)
                            .fontWeight(.semibold)
                        
                        // 2. 食物
                        Text("- \(entry.name)")
                        
                        Spacer()
                        
                        // 3. 日期(右侧对齐，字体略小)
                        Text("\(entry.date, formatter: dateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("历史记录")
            .onAppear(perform: loadEntries)
        }
    }
    
    private func loadEntries() {
        do {
            // 从数据库获取所有 FoodEntry
            let allEntries = try modelContext.fetch(FetchDescriptor<FoodEntry>())
            // 按时间倒序
            foodEntries = allEntries.sorted { $0.date > $1.date }
        } catch {
            print("❌ 加载历史记录失败: \(error.localizedDescription)")
        }
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entryToDelete = foodEntries[index]
            modelContext.delete(entryToDelete)
        }
        do {
            try modelContext.save()
            foodEntries.remove(atOffsets: offsets)
        } catch {
            print("❌ 删除失败: \(error.localizedDescription)")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short   // 例如 “2/5/25”
        f.timeStyle = .short   // 例如 “2:27 PM”
        return f
    }
}
