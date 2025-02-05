import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 声明需要管理的模型类型
                .modelContainer(for: [FoodEntry.self, FoodCategory.self])
        }
    }
}
