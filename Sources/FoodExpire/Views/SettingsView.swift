import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var processing = false

    var body: some View {
        Form {
            Section("通知") {
                Toggle("通知オン", isOn: $notificationManager.notificationsEnabled)
            }
            Section {
                if userSettings.isPremium {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("広告非表示購入済み")
                    }
                } else {
                    Button(action: { Task { await purchase() } }) {
                        Text("広告を削除 (¥480)")
                    }
                }
                Button("復元") {
                    Task { await restore() }
                }
            }
            Section("アプリについて") {
                Text("賞味期限を管理するシンプルなアプリです")
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("設定")
        .disabled(processing)
    }

    private func purchase() async {
        processing = true
        let success = await InAppPurchaseManager.purchaseRemoveAds()
        processing = false
        if success { userSettings.isPremium = true }
    }

    private func restore() async {
        processing = true
        let success = await InAppPurchaseManager.restorePurchases()
        processing = false
        if success { userSettings.isPremium = true }
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environmentObject(UserSettings())
        .environmentObject(NotificationManager.shared)
}
