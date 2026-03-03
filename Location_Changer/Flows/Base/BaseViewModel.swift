import UIKit
import Combine
import MapKit
import CoreLocation

@MainActor
final class BaseViewModel {
    
    static let shared = BaseViewModel()
    private let locationManager = LocationManager.shared
    private let networkManager = NetworkManager.shared
    private let apphudManager = ApphudManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .none
    
    @Published var exifData: EXIFData?
    var beforeData: EXIFData?
    
    let EXIFSection: [EXIFSection] = [
        .init(header: "", items: .photo),
        .init(header: String(localized: "Presets"), items: .presets),
        .init(header: String(localized: "Manual setting"), items: .coordinates),
        .init(header: "", items: .date),
        .init(header: "", items: .device),
        .init(header: "", items: .before_after)
    ]
    private let settingsData: [SettingsData] = [
        .init(header: "", entity: [.banner]),
        .init(header: String(localized: "Manage plan"), entity: [.manage_plan]),
        .init(header: String(localized: "GPS accuracy"), entity: [.gps_accuracy]),
        .init(header: String(localized: "Legal & Info"), entity: [.support, .restore, .terms_privacy])
    ]
    func getSettingsData() -> [SettingsData] {
        return settingsData.compactMap { $0.filter(AppData.premiumAccess) }
    }
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
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
}
extension BaseViewModel {
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
    func restore() {
        apphudManager.restore()
    }
    
    
    
    
    
    
    
}
