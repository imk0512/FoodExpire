import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct FoodExpireApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var userSettings = UserSettings()

    init() {
        FirebaseApp.configure()
        notificationManager.requestAuthorization()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .environmentObject(userSettings)
                .onAppear {
                    notificationManager.reloadSchedule()
                }
        }
    }
}
