import SwiftUI
import SwiftData

struct CategoryEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\FoodCategory.type)])
    var categories: [FoodCategory]
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    
    @State private var selectedCategory: FoodCategory?
    @State private var showingFoodEdit = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.type) { category in
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
            }
            .navigationTitle("编辑食物类别")
            .navigationBarItems(
                leading: Button("完成") { dismiss() },
                trailing: Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus")
                }
            )
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
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        let category = FoodCategory(type: newCategoryName, foods: [])
        modelContext.insert(category)
        newCategoryName = ""
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categories[index])
        }
    }
}
