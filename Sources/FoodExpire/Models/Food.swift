import Foundation
import FirebaseFirestoreSwift

enum StorageType: String, CaseIterable, Codable, Identifiable {
    case 冷蔵, 冷凍, 常温
    var id: String { rawValue }
}

struct Food: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var imageUrl: String
    var expireDate: Date
    var storageType: StorageType = .冷蔵
}

