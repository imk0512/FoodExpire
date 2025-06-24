import SwiftUI
import FirebaseCore

@main
struct FoodExpireApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
