import SwiftUI

struct FoodListView: View {
    @StateObject private var viewModel = FoodListViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List(viewModel.foods) { food in
                FoodCardView(food: food)
            }
            .listStyle(.plain)
            .navigationTitle("食品一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear { viewModel.fetchFoods() }
            .sheet(isPresented: $showAdd) {
                AddFoodView()
            }
        }
    }
}

#Preview {
    FoodListView()
}

