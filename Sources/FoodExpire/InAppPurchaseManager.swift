import Foundation
import StoreKit

enum StoreError: Error {
    case failedVerification
}

struct InAppPurchaseManager {
    static let removeAdsID = "remove_ads"

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    static func purchaseRemoveAds() async -> Bool {
        do {
            guard let product = try await Product.products(for: [removeAdsID]).first else {
                return false
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                UserDefaults.standard.set(true, forKey: "isPremium")
                return true
            default:
                return false
            }
        } catch {
            return false
        }
    }

    static func restorePurchases() async -> Bool {
        do {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   transaction.productID == removeAdsID {
                    UserDefaults.standard.set(true, forKey: "isPremium")
                    return true
                }
            }
        } catch {
            return false
        }
        return false
    }

    static func syncPremiumStatus() async -> Bool {
        do {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   transaction.productID == removeAdsID {
                    UserDefaults.standard.set(true, forKey: "isPremium")
                    return true
                }
            }
        } catch {
            return UserDefaults.standard.bool(forKey: "isPremium")
        }
        UserDefaults.standard.set(false, forKey: "isPremium")
        return false
    }
}
