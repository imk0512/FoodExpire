import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FoodDetailViewModel: ObservableObject {
    @Published var food: Food
    init(food: Food) {
        self.food = food
    }

    func updateFood() {
        guard let id = food.id else { return }
        let data: [String: Any] = [
            "name": food.name,
            "expireDate": Timestamp(date: food.expireDate),
            "updatedAt": Timestamp(date: Date())
        ]
        Firestore.firestore().collection("foods").document(id).updateData(data)
    }

    func deleteFood() {
        guard let id = food.id else { return }
        Firestore.firestore().collection("foods").document(id).delete()
    }
}
