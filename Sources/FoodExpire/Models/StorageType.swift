import Foundation

enum StorageType: String, CaseIterable, Codable, Identifiable {
    case fridge = "冷蔵"
    case freezer = "冷凍"
    case room = "常温"

    var id: String { rawValue }
}
