import Foundation
import UserNotifications
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    @Published var selectedFood: Food?
    @Published var showSettingsAlert = false
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                requestAuthorization()
            } else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        }
    }

    private override init() {
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        super.init()
    }

    func requestAuthorization() {
        guard notificationsEnabled else { return }
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                self.reloadSchedule()
            }
            if !granted {
                DispatchQueue.main.async {
                    self.notificationsEnabled = false
                    self.showSettingsAlert = true
                }
            }
        }
    }

    func reloadSchedule() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        Firestore.firestore().collection("foods").getDocuments { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else { return }
            for doc in documents {
                if let food = try? doc.data(as: Food.self) {
                    self.scheduleNotification(for: food)
                }
            }
        }
    }

    func scheduleNotification(for food: Food) {
        guard let id = food.id else { return }
        let content = UNMutableNotificationContent()
        content.title = "賞味期限のお知らせ"
        let days = Calendar.current.dateComponents([.day], from: Date(), to: food.expireDate).day ?? 0
        content.body = "『\(food.name)』の賞味期限が(\(days)日後)に迫っています。"
        content.sound = .default
        content.userInfo = ["foodId": id]

        let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: food.expireDate) ?? food.expireDate
        var components = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = 9
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "food_\(id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["food_\(id)"])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let id = response.notification.request.content.userInfo["foodId"] as? String {
            Firestore.firestore().collection("foods").document(id).getDocument { doc, _ in
                if let doc = doc, let food = try? doc.data(as: Food.self) {
                    self.selectedFood = food
                }
            }
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
