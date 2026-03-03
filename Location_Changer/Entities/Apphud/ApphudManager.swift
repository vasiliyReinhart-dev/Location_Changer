import UIKit
import ApphudSDK
import StoreKit
import Combine

final class ApphudManager {
    
    static let shared = ApphudManager()
    
    @Published var cachedProducts: [PaywallProduct] = []
    @Published var subscriptionStatus: SubscriptionStatus = .none
    
    private(set) var cachedPaywall: ApphudPaywall?
    private(set) var purchaseResult: ApphudPurchaseResult?
    
    func fetchPaywall() async {
        await Apphud.paywallsDidLoadCallback { paywalls, arg in
            if let paywall = paywalls.first(where: { $0.identifier == PaywallKey.paywallKey }) {
                self.cachedPaywall = paywall
                let products = self.mapProducts(paywall)
                self.cachedProducts = products
                Apphud.paywallShown(paywall)
            } else {
                print("Paywall не найден")
            }
        }
    }
    private func mapProducts(_ paywall: ApphudPaywall) -> [PaywallProduct] {
        return paywall.products.map {
            PaywallProduct( name: $0.duration()?.name,
                            productId: $0.productId,
                            price: $0.productPrice,
                            currency: Locale.current.currencySymbol,
                            trial: $0.hasTrial,
                            subscriptionPeriod: $0.duration(),
                            original: $0)
        }
    }
    func purchase(_ product: ApphudProduct?) {
        guard let product = cachedPaywall?.products.first(where: { $0 == product }) else { return }
        Apphud.purchase(product) { result in
            if result.error != nil {
                self.subscriptionStatus = .errorSubscribed
            }
            if result.success {
                self.subscriptionStatus = .subdscribed(Apphud.subscription())
            } else {
                self.subscriptionStatus = .notSubscribed
            }
        }
    }
    func restore() {
        Apphud.restorePurchases { subscriptions, purchases, error in
            if let error = error {
                print("Restore error: \(error.localizedDescription)")
                self.subscriptionStatus = .errorRestore
                return
            }
            if Apphud.hasActiveSubscription() || (subscriptions?.isEmpty == false) || (purchases?.isEmpty == false) {
                self.subscriptionStatus = .restored
            } else {
                self.subscriptionStatus = .notRestored
            }
        }
    }
    func hasActiveSubscription(_ completion: @escaping (Bool) -> Void) {
         let isActive = Apphud.hasActiveSubscription()
         completion(isActive)
     }
     func hasPremiumAccess(_ completion: @escaping (Bool) -> Void) {
         let isActive = Apphud.hasPremiumAccess()
         completion(isActive)
     }
    func checkNonRenewingPurchaseActive() -> [String] {
        var purchases: [String] = []
        cachedProducts.forEach {
            if Apphud.isNonRenewingPurchaseActive(productIdentifier: $0.productId) {
                purchases.append($0.productId)
            }
        }
        return purchases
    }
}


extension ApphudProduct {
    var productPrice: String? {
        guard let priceProduct = skProduct?.price else {
            return nil
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter.string(from: priceProduct)
    }
    var trialPeriod: String? {
        guard let trialPeriod = skProduct?.introductoryPrice?.subscriptionPeriod else {
            return nil
        }
        let unitName = self.unitName(for: trialPeriod.unit)
        return "\(trialPeriod.numberOfUnits) \(unitName)"
    }
    var hasTrial: Bool {
        skProduct?.introductoryPrice != nil
    }
    func duration() -> SubscriptionDuration? {
        guard let subscriptionPeriod = skProduct?.subscriptionPeriod else {
            return nil
        }
        switch subscriptionPeriod.unit {
        case .day, .week: return .week
        case .month: return .month
        case .year: return .year
        @unknown default: return nil
        }
    }
    private func unitName(for unit: SKProduct.PeriodUnit) -> String {
        switch unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "unit"
        }
    }
}
