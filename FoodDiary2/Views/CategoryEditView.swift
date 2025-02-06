import SwiftUI
import SwiftData

struct CategoryEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 食物类别
    @Query(sort: [SortDescriptor(\FoodCategory.index, order: .forward)])
    var categories: [FoodCategory]
    
    // 是否展示“添加类别”对话框
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    
    // 选中的类别，用于在子界面（sheet）中编辑 Food
    @State private var selectedCategory: FoodCategory?
    @State private var showingFoodEdit = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.id) { category in
                    HStack {
                        Text(category.type)
                        Spacer()
                        Button(action: {
                            selectedCategory = category
                            showingFoodEdit = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("编辑食物类别")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showingAddCategory = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .alert("添加新类别", isPresented: $showingAddCategory) {
                TextField("类别名称", text: $newCategoryName)
                Button("取消", role: .cancel) { }
                Button("添加") { addCategory() }
            }
            .sheet(isPresented: $showingFoodEdit) {
                if let category = selectedCategory {
                    FoodEditView(category: category)
                }
            }
        }
    }
    
    // MARK: - 添加新类别
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        do {
            let fetchDescriptor = FetchDescriptor<FoodCategory>(
                sortBy: [SortDescriptor(\.index, order: .forward)]
            )
            let allCategories = try modelContext.fetch(fetchDescriptor)
            let maxIndex = allCategories.map(\.index).max() ?? 0
            
            // 新建类别
            let newCategory = FoodCategory(
                type: newCategoryName,
                foods: [],
                index: maxIndex + 1
            )
            modelContext.insert(newCategory)
            
            // 保存
            try modelContext.save()
            
            // 清理输入
            newCategoryName = ""
            showingAddCategory = false
            
        } catch {
            print("❌ 添加类别失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 删除
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let cat = categories[index]
            modelContext.delete(cat)
        }
        
        // 重新给所有剩余的对象分配 index
        for (i, cat) in categories.enumerated() {
            cat.index = i
        }
        
        // 保存
        do {
            try modelContext.save()
        } catch {
            print("❌ 删除类别失败：\(error.localizedDescription)")
        }
    }
}

