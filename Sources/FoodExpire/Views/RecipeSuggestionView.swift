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
                    .titleFont()
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
                .padding(.vertical, 8)
                Button("使う") {
                    viewModel.useFoods()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            Button("別の提案を見る") {
                viewModel.generateRecipe()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.vertical, 8)
        .navigationTitle("レシピ提案")
        .onAppear { viewModel.fetchFoods() }
        .alert("データの取得に失敗しました", isPresented: $viewModel.fetchError) {}
    }
}

#Preview {
    NavigationStack { RecipeSuggestionView() }
}
