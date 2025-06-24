import SwiftUI

struct FoodListView: View {
    @StateObject private var viewModel = FoodListViewModel()
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var filter: StorageType?
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var notificationManager: NotificationManager

    private var displayedFoods: [Food] {
        if let filter { return viewModel.foods.filter { $0.storageType == filter } }
        return viewModel.foods
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("保存場所", selection: $filter) {
                    Text("すべて").tag(StorageType?.none)
                    ForEach(StorageType.allCases) { type in
                        Text(type.rawValue).tag(Optional(type))
                    }
                }
                .pickerStyle(.segmented)

                List(displayedFoods) { food in
                    NavigationLink {
                        FoodDetailView(food: food)
                    } label: {
                        FoodCardView(food: food)
                    }
                }
                .listStyle(.plain)
            }
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

