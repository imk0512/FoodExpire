import SwiftUI
import FirebaseCore

@main
struct FoodExpireApp: App {
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        FirebaseApp.configure()
        notificationManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.reloadSchedule()
                }
        }
    }
}
