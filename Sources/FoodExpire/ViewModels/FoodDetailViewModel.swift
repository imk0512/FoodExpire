import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FoodDetailViewModel: ObservableObject {
    @Published var food: Food
    init(food: Food) {
        self.food = food
    }

    func updateFood(completion: @escaping (Error?) -> Void) {
        guard let id = food.id else { completion(nil); return }
        let data: [String: Any] = [
            "name": food.name,
            "expireDate": Timestamp(date: food.expireDate),
            "updatedAt": Timestamp(date: Date()),
            "note": food.note ?? "",
            "storageType": food.storageType ?? ""
        ]
        Firestore.firestore().collection("foods").document(id).updateData(data) { error in
            if error == nil {
                NotificationManager.shared.scheduleNotification(for: self.food)
            }
            completion(error)
        }
    }

    func deleteFood(completion: @escaping (Error?) -> Void) {
        guard let id = food.id else { completion(nil); return }
        Firestore.firestore().collection("foods").document(id).delete { error in
            if error == nil {
                NotificationManager.shared.cancelNotification(for: id)
            }
            completion(error)
        }
    }
}
