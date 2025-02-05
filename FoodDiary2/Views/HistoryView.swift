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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("类型: \(entry.type)")
                            .font(.headline)
                        Text("食物: \(entry.name)")
                        Text("日期: \(entry.date, formatter: dateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("历史记录")
            .onAppear(perform: loadEntries)
        }
    }
    
    /// 手动加载全部 FoodEntry
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
    
    /// 左滑删除
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
        f.dateStyle = .short
        f.timeStyle = .medium
        return f
    }
}
