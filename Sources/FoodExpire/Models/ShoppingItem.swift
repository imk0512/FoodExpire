import Foundation
import FirebaseFirestoreSwift

struct ShoppingItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var createdAt: Date
    var note: String?
    var storageType: String?
    var isChecked: Bool
}
