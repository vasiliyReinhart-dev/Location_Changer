import UIKit
import ApphudSDK
import Combine

@MainActor
final class PaywallViewModel {
    
    static let shared = PaywallViewModel()
    private let apphudManager = ApphudManager.shared
    
    private var task: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var products: [PaywallProduct] = []
    @Published private(set) var paywallData: PaywallData?
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .none
    
    let sections: [MainSection] = [.header, .product, .info]
    private let paywallInfoData: [PaywallInfoData] = [
        .init(icon: UIImage(named: "info1"),
              header: String(localized: "Change Your GPS Anywhere"),
              subscription: String(localized: "Set your location to any place in the world instantly")),
        .init(icon: UIImage(named: "info2"),
              header: String(localized: "Save Favorite Locations"),
              subscription: String(localized: "Keep your most used places one tap away")),
        .init(icon: UIImage(named: "info3"),
              header: String(localized: "Unlimited Teleports"),
              subscription: String(localized: "Move between locations as often as you want")),
        .init(icon: UIImage(named: "info4"),
              header: String(localized: "Fast & Accurate"),
              subscription: String(localized: "Precise GPS changes with instant response")),
        .init(icon: UIImage(named: "info5"),
              header: String(localized: "Custom Location Sharing"),
              subscription: String(localized: "Share your current location with friends easily")),
        .init(icon: UIImage(named: "info6"),
              header: String(localized: "Location History Tracking"),
              subscription: String(localized: "Review and manage your previous locations effortlessly"))
    ]
    
    func clickAnimate(_ view: UIView,
                      _ duration: Double = 0.2,
                      _ scale: Double = 0.96) {
        UIView.animate(withDuration: duration, animations: {
            view.transform = CGAffineTransform(scaleX: scale,
                                               y: scale)
        }, completion: { finished in
            UIView.animate(withDuration: duration) {
                view.transform = CGAffineTransform(scaleX: 1,
                                                   y: 1)
            }
        })
    }
    
    init() {
        viewDidload()
        loadProduct()
    }
    func viewDidload() {
        apphudManager.$cachedProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProducts in
                guard let self = self else { return }
                self.products = updatedProducts
                self.paywallData = PaywallData(header: String(localized: "Unlock Location Changer"),
                                               description: String(localized: "Change your GPS location anywhere — instantly and reliably"),
                                               info: paywallInfoData,
                                               product: updatedProducts)
            }
            .store(in: &cancellables)
    }
    func subscribeToStatus() {
        ApphudManager.shared.$subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .restored:
                    AppData.premiumAccess = true
                case .subdscribed(let data):
                    AppData.premiumAccess = true
                    print("subdscribed: \(data)")
                default: break
                }
                self?.subscriptionStatus = status
            }
            .store(in: &cancellables)
    }
    func loadProduct() {
        Task {
            await apphudManager.fetchPaywall()
        }
    }
    func purchase(_ product: ApphudProduct?)  {
        apphudManager.purchase(product)
    }
    func restore() {
        apphudManager.restore()
    }
}

