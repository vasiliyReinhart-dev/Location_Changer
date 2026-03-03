
import UIKit

enum SettingsEntities: CaseIterable {
    case banner
    // Manage plan
    case manage_plan
    // GPS accuracy
    case gps_accuracy
    // Legal & Info
    case support, restore, terms_privacy
    
    var name: String {
        switch self {
        case .banner: return ""
        case .manage_plan: return String(localized: "Subscription")
        case .gps_accuracy: return ""
        case .support: return String(localized: "Contact support")
        case .restore: return String(localized: "Restore purchase")
        case .terms_privacy: return String(localized: "Terms / Privacy")
        }
    }
    var icon: UIImage? {
        switch self {
        case .banner: return UIImage(named: "pro_banner")
        case .manage_plan: return UIImage(named: "manage_plan_icon")
        case .gps_accuracy: return nil
        case .support: return UIImage(named: "support_icon")
        case .restore: return UIImage(named: "restore_icon")
        case .terms_privacy: return UIImage(named: "terms_privacy_icon")
        }
    }
    func shouldShow(_ isFullAccess: Bool) -> Bool {
        switch self {
        case .banner: return !isFullAccess
        default: return true
        }
    }
}
struct SettingsData {
    let header: String
    let entity: [SettingsEntities]
}
extension SettingsData {
    func filter(_  isFullAccess: Bool) -> SettingsData? {
        let filteredEntities = entity.filter { $0.shouldShow(isFullAccess) }
        guard !filteredEntities.isEmpty else { return nil }
        return SettingsData(header: header, entity: filteredEntities)
    }
}
