import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @State private var processing = false

    var body: some View {
        Form {
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
}
