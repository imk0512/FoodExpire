import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class RecipeSuggestionViewModel: ObservableObject {
    @Published var foods: [Food] = []
    @Published var suggestedFoods: [Food] = []
    @Published var recipeTitle: String = ""
    @Published var fetchError = false

    private let templates2 = [
        "%@と%@の炒め物",
        "%@と%@のサラダ",
        "%@と%@の煮込み",
        "%@と%@のバター炒め",
        "%@と%@の和え物"
    ]

    private let templates3 = [
        "%@・%@・%@のミックス炒め",
        "%@と%@と%@のスープ",
        "%@・%@・%@の簡単煮"
    ]

    func fetchFoods() {
        Firestore.firestore()
            .collection("foods")
            .order(by: "expireDate")
            .limit(to: 10)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if error != nil {
                    self.fetchError = true
                    return
                }
                self.foods = snapshot?.documents.compactMap { try? $0.data(as: Food.self) } ?? []
                self.generateRecipe()
            }
    }

    func generateRecipe() {
        guard foods.count >= 2 else {
            suggestedFoods = []
            recipeTitle = ""
            return
        }
        let shuffled = foods.shuffled()
        let useCount = min(shuffled.count >= 3 ? Int.random(in: 2...3) : 2, shuffled.count)
        suggestedFoods = Array(shuffled.prefix(useCount))

        if useCount == 2 {
            if let template = templates2.randomElement() {
                recipeTitle = String(format: template, suggestedFoods[0].name, suggestedFoods[1].name)
            }
        } else {
            if let template = templates3.randomElement() {
                recipeTitle = String(format: template, suggestedFoods[0].name, suggestedFoods[1].name, suggestedFoods[2].name)
            }
        }
    }

    func useFoods() {
        for food in suggestedFoods {
            guard let id = food.id else { continue }
            Firestore.firestore().collection("foods").document(id).delete()
        }
        fetchFoods()
    }
}
