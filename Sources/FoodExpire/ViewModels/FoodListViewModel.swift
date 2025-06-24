import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FoodListViewModel: ObservableObject {
    @Published var foods: [Food] = []
    @Published var fetchError: Bool = false
    @Published var filter: StorageType? = nil

    var filteredFoods: [Food] {
        guard let filter = filter else { return foods }
        return foods.filter { $0.storageType == filter }
    }

    func fetchFoods() {
        Firestore.firestore()
            .collection("foods")
            .order(by: "expireDate")
            .addSnapshotListener { [weak self] snapshot, error in
                if error != nil {
                    self?.fetchError = true
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.foods = documents.compactMap { try? $0.data(as: Food.self) }
            }
    }
}

