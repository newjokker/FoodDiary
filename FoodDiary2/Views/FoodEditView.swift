import SwiftUI
import SwiftData

struct FoodEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var category: FoodCategory
    
    @State private var showingAddFood = false
    @State private var newFoodName = ""
    @State private var editingCategoryName = false
    @State private var categoryName = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("类别名称")) {
                    HStack {
                        if editingCategoryName {
                            TextField("类别名称", text: $categoryName)
                        } else {
                            Text(category.type)
                        }
                        Spacer()
                        Button(action: {
                            if editingCategoryName {
                                // 保存新的类别名称
                                category.type = categoryName.isEmpty ? "未命名" : categoryName
                            }
                            editingCategoryName.toggle()
                        }) {
                            Image(systemName: editingCategoryName ? "checkmark.circle" : "pencil")
                        }
                    }
                }
                
                Section(header: Text("食物列表")) {
                    ForEach(category.foods, id: \.self) { food in
                        Text(food)
                    }
                    .onDelete(perform: deleteFoods)
                    .onMove(perform: moveFoods)
                }
            }
            .navigationTitle("编辑食物类别")
            .navigationBarItems(
                leading: Button("完成") { dismiss() },
                trailing: HStack {
                    EditButton()
                    Button(action: { showingAddFood = true }) {
                        Image(systemName: "plus")
                    }
                }
            )
            .alert("添加新食物", isPresented: $showingAddFood) {
                TextField("食物名称", text: $newFoodName)
                Button("取消", role: .cancel) { }
                Button("添加") { addFood() }
            }
            .onAppear {
                categoryName = category.type
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
    
    private func moveFoods(from source: IndexSet, to destination: Int) {
        category.foods.move(fromOffsets: source, toOffset: destination)
    }
}

