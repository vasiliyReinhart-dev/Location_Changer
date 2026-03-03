import UIKit
import ApphudSDK

enum PaywallKey {
    static let apphudKey = "app_SotEMU5JM7DxQZGAiHysJ6pySiszTP"
    static let paywallKey = "main"
    static let campaign = "campaign_trigger"
}

enum SubscriptionStatus {
    case none
    case subdscribed(ApphudSubscription?)
    case notSubscribed
    case errorSubscribed
    
    case restored
    case notRestored
    case errorRestore
}
struct PaywallProduct {
    var name: String?
    var productId: String
    var price: String?
    var currency: String?
    var trial: Bool?
    var subscriptionPeriod: SubscriptionDuration?
    var original: ApphudProduct?
}
enum SubscriptionDuration {
    case week, month, year, unowned

    var name: String {
        switch self {
        case .week: return String(localized: "Weekly")
        case .month: return String(localized: "Monthly")
        case .year: return String(localized: "Yearly")
        case .unowned: return "unowned"
        }
    }
}
