import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FoodListViewModel: ObservableObject {
    @Published var foods: [Food] = []
    @Published var fetchError: Bool = false

    func fetchFoods() {
        Firestore.firestore()
            .collection("foods")
            .order(by: "expireDate")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("fetch error: \(error)")
                    self?.fetchError = true
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.foods = documents.compactMap { try? $0.data(as: Food.self) }
            }
    }
}

