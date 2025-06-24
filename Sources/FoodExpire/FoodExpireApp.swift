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
        Task {
            let premium = await InAppPurchaseManager.syncPremiumStatus()
            await MainActor.run { userSettings.isPremium = premium }
        }
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
