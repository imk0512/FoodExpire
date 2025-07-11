import SwiftUI

struct FoodListView: View {
    @StateObject private var viewModel = FoodListViewModel()
    @State private var showAdd = false
    @State private var showSettings = false
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var notificationManager: NotificationManager

    var body: some View {
        NavigationStack {
            List(viewModel.foods) { food in
                NavigationLink {
                    FoodDetailView(food: food)
                } label: {
                    FoodCardView(food: food)
                }
            }
            .listStyle(.plain)
            .padding(.vertical, 8)
            .navigationTitle("食品一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear { viewModel.fetchFoods() }
            .alert("データの取得に失敗しました", isPresented: $viewModel.fetchError) {}
            .sheet(isPresented: $showAdd) {
                AddFoodView()
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack { SettingsView() }
                    .environmentObject(userSettings)
                    .environmentObject(notificationManager)
            }
            .safeAreaInset(edge: .bottom) {
                if !userSettings.isPremium {
                    BannerAdView()
                        .frame(height: 50)
                }
            }
        }
    }
}

#Preview {
    FoodListView()
        .environmentObject(UserSettings())
        .environmentObject(NotificationManager.shared)
}

