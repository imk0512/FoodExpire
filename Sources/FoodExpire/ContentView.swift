import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var notificationManager: NotificationManager

    var body: some View {
        FoodListView()
            .sheet(item: $notificationManager.selectedFood) { food in
                NavigationStack {
                    FoodDetailView(food: food)
                }
            }
    }
}

#Preview {
    ContentView()
}

