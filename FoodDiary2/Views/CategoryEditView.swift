import SwiftUI
import SwiftData

struct CategoryEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 食物类别（默认按 index 排序，或者你可以用其它字段）
    @Query(sort: [SortDescriptor(\FoodCategory.index, order: .forward)])
    var categories: [FoodCategory]
    
    // 是否展示“添加类别”对话框
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    
    // 选中的类别，用于在子界面（sheet）中编辑 Food
    @State private var selectedCategory: FoodCategory?
    @State private var showingFoodEdit = false
    
    // --------- 关键的新增字段 ----------
    // 用于在界面中拖动排序的本地数组
    @State private var localCategories: [FoodCategory] = []
    // 用于切换List的编辑模式
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            List {
                ForEach(localCategories, id: \.id) { category in
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
                .onDelete(perform: deleteCategories)
                .onMove(perform: moveCategory)  // <--- 允许拖动修改顺序
            }
            // 将 editMode 绑定到 List，以启用/禁用拖动功能
            .environment(\.editMode, $editMode)
            
            .navigationTitle("编辑食物类别")
            // 导航栏左侧和右侧按钮
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // 点击“+”添加类别
                        Button {
                            showingAddCategory = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        // SwiftUI 提供的编辑按钮
                        EditButton()
                    }
                }
            }
            
            // 弹窗 - 输入新类别名称
            .alert("添加新类别", isPresented: $showingAddCategory) {
                TextField("类别名称", text: $newCategoryName)
                Button("取消", role: .cancel) { }
                Button("添加") { addCategory() }
            }
            
            // 弹窗 - 编辑某个类别下的食物
            .sheet(isPresented: $showingFoodEdit) {
                if let category = selectedCategory {
                    FoodEditView(category: category)
                }
            }
            
            // 当视图出现时，把 Query 得到的 categories 复制到 localCategories
            .onAppear {
                localCategories = categories
            }
            // 如果 categories 改变（可能是别处增删），也自动同步到 localCategories
            .onChange(of: categories) { newValue in
                localCategories = newValue
            }
        }
    }
    
    // MARK: - 添加新类别
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        do {
            // 1. 获取所有现有的 Category，找到最大的 index
            let fetchDescriptor = FetchDescriptor<FoodCategory>(
                sortBy: [SortDescriptor(\.index, order: .forward)]
            )
            let allCategories = try modelContext.fetch(fetchDescriptor)
            let maxIndex = allCategories.map(\.index).max() ?? 0
            
            // 2. 新建类别，index = maxIndex + 1
            let newCategory = FoodCategory(type: newCategoryName,
                                           foods: [],
                                           index: maxIndex + 1)
            modelContext.insert(newCategory)
            
            // 3. 保存 & 清理输入
            try modelContext.save()
            newCategoryName = ""
            showingAddCategory = false
            
        } catch {
            print("❌ 添加类别失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 删除
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(localCategories[index])
        }
        // 同步删除本地数组
        localCategories.remove(atOffsets: offsets)
        
        // 更新所有剩余的 index (从0开始依次递增)
        for (i, cat) in localCategories.enumerated() {
            cat.index = i
        }
        
        // 保存
        do {
            try modelContext.save()
        } catch {
            print("❌ 删除类别失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 拖拽移动
    private func moveCategory(from source: IndexSet, to destination: Int) {
        // 1. 先移动本地数组
        localCategories.move(fromOffsets: source, toOffset: destination)
        
        // 2. 依次给每个类别重新分配 index
        for (i, cat) in localCategories.enumerated() {
            cat.index = i
        }
        
        // 3. 保存到数据库
        do {
            try modelContext.save()
        } catch {
            print("❌ 移动排序保存失败：\(error.localizedDescription)")
        }
    }
}
