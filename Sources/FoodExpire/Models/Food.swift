import Foundation
import FirebaseFirestoreSwift

struct Food: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var imageUrl: String
    var expireDate: Date
    var note: String?
}

