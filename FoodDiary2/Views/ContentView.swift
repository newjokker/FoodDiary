import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 历史记录（FoodEntry）
    @Query(sort: [SortDescriptor(\FoodEntry.date, order: .reverse)])
    var foodEntries: [FoodEntry]
    
    // 食物类别（FoodCategory）
    @Query(sort: [SortDescriptor(\FoodCategory.index, order: .forward)])
    var foodCategories: [FoodCategory]

    // 当前选中的类别、食物
    @State private var selectedType: String = ""
    @State private var selectedFood: String = ""
    
    // 控制弹窗/页面的展示
    @State private var showHistoryView = false
    @State private var showAddSuccess = false
    @State private var showEditCategories = false
    
    // 在 ContentView 中添加以下状态变量
    @State private var showAddSuccessMessage: Bool = false
    @State private var successMessage: String = ""

    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 1. 食物类型选择器
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("选择食物类型")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            showEditCategories = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(foodCategories, id: \.type) { category in
                                Button(action: { selectedType = category.type }) {
                                    Text(category.type)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedType == category.type
                                            ? Color.blue
                                            : Color.secondary.opacity(0.1)
                                        )
                                        .foregroundColor(
                                            selectedType == category.type
                                            ? .white
                                            : .primary
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // 2. 具体食物选择器
                VStack(alignment: .leading, spacing: 12) {
                    Text("选择具体食物")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    let currentFoods = getCurrentFoods()
                    if currentFoods.isEmpty {
                        Text("暂无食物项，请点击右上角编辑添加")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100), spacing: 12)
                        ], spacing: 12) {
                            ForEach(currentFoods, id: \.self) { food in
                                FoodButton(
                                    title: food,
                                    isSelected: (food == selectedFood),
                                    action: {
                                        selectedFood = food
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 3. 操作按钮
                VStack(spacing: 16) {
                    // 添加食物
                    Button(action: addFood) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("添加食物")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!selectedFood.isEmpty ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedFood.isEmpty)
                    
                    // 查看历史记录
                    Button(action: { showHistoryView = true }) {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("查看历史记录")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top)
            .navigationTitle("今天吃了什么")
            
            // 在 body 中添加淡出提示的视图
            .overlay(
                Group {
                    if showAddSuccessMessage {
                        Text("已记录：\(successMessage)") // 使用固定的 successMessage
                            .padding(12)
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .transition(.opacity)
                            .onAppear {
                                // 2 秒后自动隐藏
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showAddSuccessMessage = false
                                    }
                                }
                            }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showAddSuccessMessage)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 400)
            )
            
            // 4. 导出TXT按钮在右上角
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        exportToTxt()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            
            // 5. 编辑类别
            .sheet(isPresented: $showEditCategories) {
                CategoryEditView()
            }
            
            // 6. 添加成功的提示
            .alert("添加成功", isPresented: $showAddSuccess) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("已记录：\(selectedFood)")
            }
            
            // 7. 查看历史记录
            .sheet(isPresented: $showHistoryView) {
                HistoryView()
            }
            
            // 8. 初始化默认数据
            .onAppear {
                // 若无默认类别，初始化
                if foodCategories.isEmpty {
                    initializeDefaultCategories()
                }
                // 选中第一个类别和第一个食物
                if let firstCategory = foodCategories.first {
                    selectedType = firstCategory.type
                    if let firstFood = firstCategory.foods.first {
                        selectedFood = firstFood
                    }
                }
            }
        }
    }
    
    // MARK: - 获取当前选中类别下的所有食物
    private func getCurrentFoods() -> [String] {
        guard let currentCategory = foodCategories.first(where: { $0.type == selectedType }) else {
            return []
        }
        return currentCategory.foods
    }
    
    
    // MARK: - 初始化一些默认类别与食物
    private func initializeDefaultCategories() {
        let defaults = [
            FoodCategory(type: "🍚",  foods: ["🍚", "🍜", "🍞", "🥟", "🌽", "🥚", "🥔", "🥛"], index: 1),
            FoodCategory(type: "🍖",  foods: ["🐔", "🐷", "🐂", "🐟", "🦐"], index:2),
            FoodCategory(type: "🥬",  foods: ["🍅", "🥒", "🥬", "🥦", "🥕"], index:3),
            FoodCategory(type: "🍊",  foods: ["🍊", "🍎", "🍍", "🍑", "🍌", "🍇", "🍓"], index:4),
            FoodCategory(type: "🥤",  foods: ["🥤", "☕️", "🧋", "💧", "🍵", "🍺"], index:5),
            FoodCategory(type: "⚠️",  foods: ["🍫", "🍪", "🍬", "🌰", "🍟", "🍰", "🍦"], index:6)
        ]
        defaults.forEach { modelContext.insert($0) }
    }
    
    // MARK: - 添加一个新的 FoodEntry 条目
    private func addFood() {
        guard !selectedFood.isEmpty else { return }
        
        let newEntry = FoodEntry(type: selectedType, name: selectedFood, date: Date())
        modelContext.insert(newEntry)
        
        do {
            try modelContext.save()
            // 显示成功提示
            successMessage = selectedFood // 固定提示框的内容
            withAnimation {
                showAddSuccessMessage = true
            }
        } catch {
            print("❌ 数据保存失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 导出为 TXT 并分享
    private func exportToTxt() {
        // 1. 拼接TXT内容
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        
        let header = "类型\t食物\t时间"
        let lines = foodEntries.map { entry -> String in
            let dateString = dateFormatter.string(from: entry.date)
            return "\(entry.type)\t\(entry.name)\t\(dateString)"
        }
        let finalString = ([header] + lines).joined(separator: "\n")
        
        // 2. 日期(用于文件名)
        let filenameDateFormatter = DateFormatter()
        filenameDateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = filenameDateFormatter.string(from: Date()) // 类似 "20250205"
        
        // 3. 写入 Documents 文件夹
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "history_\(dateStr).txt"
        let txtURL = docsURL.appendingPathComponent(fileName)
        
        do {
            try finalString.write(to: txtURL, atomically: true, encoding: .utf8)
            print("✅ TXT 文件已保存: \(txtURL.path)")
            
            // 4. 调用系统分享
            shareFile(at: txtURL)
        } catch {
            print("❌ 保存 TXT 文件失败: \(error.localizedDescription)")
        }
    }
    
    /// 使用 UIActivityViewController 分享指定文件
    private func shareFile(at fileURL: URL) {
        let avc = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(avc, animated: true)
        }
    }
}
