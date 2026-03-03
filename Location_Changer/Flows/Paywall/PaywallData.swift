import UIKit
import Combine

struct PaywallInfoData {
    let icon: UIImage?
    let header: String?
    let subscription: String?
}
struct PaywallData {
    let header: String?
    let description: String?
    let info: [PaywallInfoData]
    let product: [PaywallProduct]?
}
enum CollectionItems {
    case paywall_header
    case apphud_product
    case paywall_info
}
enum MainSection {
    case header
    case product
    case info
}
extension MainSection {
    var items: [CollectionItems] {
        switch self {
        case .header: return [.paywall_header]
        case .product: return [.apphud_product]
        case .info: return [.paywall_info]
        }
    }
}
extension CollectionItems {
    var reuseID: String {
        switch self {
        case .paywall_header: return HeaderCell.id
        case .apphud_product: return ProductCell.id
        case .paywall_info: return InfoCell.id
        }
    }
    func configure(cell: UICollectionViewCell,
                   data: PaywallData?,
                   onAction: @escaping (PaywallAction) -> Void) {
        switch self {
        case .paywall_header:
            guard let cell = cell as? HeaderCell else { return }
            cell.configureCell(header: data?.header,
                               description: data?.description)
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
        case .apphud_product:
            guard let cell = cell as? ProductCell,
                  let data = data?.product else { return }
            cell.configureCell(data)
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
        case .paywall_info:
            guard let cell = cell as? InfoCell,
                  let data = data?.info else { return }
            cell.configureCell(data)
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
        }
    }
}

enum PaywallAction {
    case none
    case close
    case selectProduct(PaywallProduct?)
    case restore
    case openLink(Links)
}
enum Links: String {
    case privacy = "https://docs.google.com/document/d/1FgYpWr2T9Ca3wjjFVt4Gzz3V6pYqwud3LQ3InHWChQ4/edit?tab=t.0"
    case terms = "https://docs.google.com/document/d/1FCmD0TIIYOTzegneEN8UwapQaOLah3R1CNVs5qY1DXM/edit?tab=t.0"
}
