import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var foodEntries: [FoodEntry] = []
    
    // 按日期分组
    private var groupedEntries: [String: [FoodEntry]] {
        Dictionary(grouping: foodEntries) { entry in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: entry.date)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // 遍历每一天的分组
                ForEach(groupedEntries.keys.sorted().reversed(), id: \.self) { date in
                    Section(header: Text(date).font(.headline)) {
                        // 遍历当天的所有条目
                        ForEach(groupedEntries[date]!) { entry in
                            HStack(spacing: 8) {
                                // 1. 类型
                                Text(entry.type)
                                    .fontWeight(.semibold)
                                
                                // 2. 食物
                                Text("- \(entry.name)")
                                
                                Spacer()
                                
                                // 3. 时间(右侧对齐，字体略小)
                                Text("\(entry.date, formatter: timeFormatter)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            deleteEntries(at: offsets, for: date)
                        }
                    }
                }
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
    
    private func deleteEntries(at offsets: IndexSet, for date: String) {
        if let entries = groupedEntries[date] {
            for index in offsets {
                let entryToDelete = entries[index]
                modelContext.delete(entryToDelete)
            }
            do {
                try modelContext.save()
                // 重新加载数据
                loadEntries()
            } catch {
                print("❌ 删除失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 时间格式化器
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short   // 例如 “2:27 PM”
        return f
    }
}
