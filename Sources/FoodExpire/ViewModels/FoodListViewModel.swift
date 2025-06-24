import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FoodListViewModel: ObservableObject {
    @Published var foods: [Food] = []

    func fetchFoods() {
        Firestore.firestore()
            .collection("foods")
            .order(by: "expireDate")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.foods = documents.compactMap { try? $0.data(as: Food.self) }
            }
    }
}

