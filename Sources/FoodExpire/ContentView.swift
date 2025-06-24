import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var notificationManager: NotificationManager

    var body: some View {
        TabView {
            FoodListView()
                .tabItem { Label("食品", systemImage: "list.bullet") }
            NavigationStack { ShoppingListView() }
                .tabItem { Label("買い物", systemImage: "cart") }
        }
        .sheet(item: $notificationManager.selectedFood) { food in
            NavigationStack {
                FoodDetailView(food: food)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotificationManager.shared)
        .environmentObject(UserSettings())
}

