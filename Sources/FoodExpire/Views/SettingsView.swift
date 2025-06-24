import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var processing = false
    @State private var showPurchaseErrorAlert = false
    @State private var showRestoreErrorAlert = false

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
        .alert("購入に失敗しました", isPresented: $showPurchaseErrorAlert) {}
        .alert("復元に失敗しました", isPresented: $showRestoreErrorAlert) {}
        .alert("通知が許可されていません。設定から許可してください", isPresented: $notificationManager.showSettingsAlert) {
            Button("設定を開く") { openSettings() }
            Button("OK", role: .cancel) {}
        }
    }

    private func purchase() async {
        processing = true
        let success = await InAppPurchaseManager.purchaseRemoveAds()
        processing = false
        if success {
            userSettings.isPremium = true
        } else {
            showPurchaseErrorAlert = true
        }
    }

    private func restore() async {
        processing = true
        let success = await InAppPurchaseManager.restorePurchases()
        processing = false
        if success {
            userSettings.isPremium = true
        } else {
            showRestoreErrorAlert = true
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environmentObject(UserSettings())
        .environmentObject(NotificationManager.shared)
}
