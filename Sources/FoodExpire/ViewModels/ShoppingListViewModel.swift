import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class ShoppingListViewModel: ObservableObject {
    @Published var items: [ShoppingItem] = []
    @Published var fetchError = false

    func fetchItems() {
        Firestore.firestore()
            .collection("shoppingList")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if error != nil {
                    self?.fetchError = true
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.items = documents.compactMap { try? $0.data(as: ShoppingItem.self) }
            }
    }

    func toggleChecked(_ item: ShoppingItem) {
        guard let id = item.id else { return }
        Firestore.firestore().collection("shoppingList").document(id)
            .updateData(["isChecked": !item.isChecked])
    }

    func deleteItem(_ item: ShoppingItem) {
        guard let id = item.id else { return }
        Firestore.firestore().collection("shoppingList").document(id).delete()
    }
}
