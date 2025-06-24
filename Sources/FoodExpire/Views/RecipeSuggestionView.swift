import SwiftUI

struct RecipeSuggestionView: View {
    @StateObject private var viewModel = RecipeSuggestionViewModel()

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.suggestedFoods.isEmpty {
                Text("食品が不足しています")
                    .foregroundStyle(.secondary)
            } else {
                Text(viewModel.recipeTitle)
                    .font(.title2)
                    .bold()
                List(viewModel.suggestedFoods) { food in
                    HStack {
                        Text(food.name)
                        Spacer()
                        Text(DateFormatter.expireFormatter.string(from: food.expireDate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .listStyle(.plain)
                Button("使う") {
                    viewModel.useFoods()
                }
                .buttonStyle(.borderedProminent)
            }
            Button("別の提案を見る") {
                viewModel.generateRecipe()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("レシピ提案")
        .onAppear { viewModel.fetchFoods() }
        .alert("データの取得に失敗しました", isPresented: $viewModel.fetchError) {}
    }
}

#Preview {
    NavigationStack { RecipeSuggestionView() }
}
