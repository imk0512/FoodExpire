import Foundation

final class UserSettings: ObservableObject {
    @Published var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }

    init() {
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
}
