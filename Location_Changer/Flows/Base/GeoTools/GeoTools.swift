import UIKit
import Combine
import CoreLocation

enum GeoTools: CaseIterable {
    case editEXIEF
    
    var name: String? {
        switch self {
        case .editEXIEF: return String(localized: "EXIF Editor")
        }
    }
    var icon: UIImage? {
        switch self {
        case .editEXIEF: return UIImage(named: "word_icon")
        }
    }
}

struct RawMetadata {
    var date: Date?
    var location: CLLocation?
    var model: String?
}

enum EXIFAction {
    case none
    case different_photo
    case select_presets(Presets)
    case open_map
    case random_info
    case save
    case update_hidden(EXIFTools, Bool)
    case updateDate(Date)
    case updateModel(String?)
}

enum Presets: CaseIterable {
    case social, anonym, only_location, Own
    
    var icon: UIImage? {
        switch self {
        case .social: return UIImage(named: "preset_1")
        case .anonym: return UIImage(named: "preset_2")
        case .only_location: return UIImage(named: "preset_3")
        case .Own: return UIImage(named: "preset_4")
        }
    }
    var iconSelect: UIImage? {
        switch self {
        case .social: return UIImage(named: "preset_1_s")
        case .anonym: return UIImage(named: "preset_2_s")
        case .only_location: return UIImage(named: "preset_3_s")
        case .Own: return UIImage(named: "preset_4_s")
        }
    }
    var name: String? {
        switch self {
        case .social: return String(localized: "Social")
        case .anonym: return String(localized: "Anonym")
        case .only_location: return String(localized: "Only Location")
        case .Own: return String(localized: "Own")
        }
    }
    var title: String? {
        switch self {
        case .social: return String(localized: "Clear the location")
        case .anonym: return String(localized: "Clear all")
        case .only_location: return String(localized: "Hide geo")
        case .Own: return String(localized: "Manual setting")
        }
    }
    var hidenData: EXIFData? {
        switch self {
        case .social: return EXIFData(hideCoordinate: true, hideDate: false, hideModel: false)
        case .anonym: return EXIFData(hideCoordinate: true, hideDate: true, hideModel: true)
        case .only_location: return EXIFData(hideCoordinate: false, hideDate: true, hideModel: true)
        case .Own: return EXIFData(hideCoordinate: false, hideDate: false, hideModel: false)
        }
    }
}

struct EXIFData {
    var image: UIImage?
    var presets: Presets?
    var location: CLLocation?
    var hideCoordinate: Bool
    var date: Date?
    var hideDate: Bool
    var deviceModel: String?
    var hideModel: Bool
    
    mutating func apply(preset: Presets) {
        self.presets = preset
        guard let presetData = preset.hidenData else { return }
        
        self.hideCoordinate = presetData.hideCoordinate
        self.hideDate = presetData.hideDate
        self.hideModel = presetData.hideModel
        
    }
}
extension EXIFData {
    init(hideCoordinate: Bool, hideDate: Bool, hideModel: Bool) {
        self.image = nil
        self.presets = nil
        self.location = nil
        self.date = Date()
        self.deviceModel = nil
        self.hideCoordinate = hideCoordinate
        self.hideDate = hideDate
        self.hideModel = hideModel
    }
}

enum EXIFTools {
    case photo, presets, coordinates, date, device, before_after
}

struct EXIFSection {
    let header: String
    let items: EXIFTools
}

extension EXIFTools {
    var reuseID: String {
        switch self {
        case .photo: return PhotoCell.id
        case .presets: return PresetsCell.id
        case .coordinates: return CoordinatesCell.id
        case .date: return DateEndTimeCell.id
        case .device: return DeviceCell.id
        case .before_after: return BeforeAndAfterCell.id
        }
    }
    func configure(cell: UICollectionViewCell,
                   data: EXIFData?,
                   beforeData: EXIFData?,
                   onAction: @escaping (EXIFAction) -> Void) {
        switch self {
        case .photo:
            guard let cell = cell as? PhotoCell else { return }
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
            cell.configure(data?.image)
        case .presets:
            guard let cell = cell as? PresetsCell,
                  let data else { return }
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
            cell.configure(data)
        case .coordinates:
            guard let cell = cell as? CoordinatesCell,
                    let data else { return }
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
            cell.configure(data)
        case .date:
            guard let cell = cell as? DateEndTimeCell,
                  let data else { return }
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
            cell.configure(data)
        case .device:
            guard let cell = cell as? DeviceCell,
                  let data else { return }
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
            cell.configure(data)
        case .before_after:
            guard let cell = cell as? BeforeAndAfterCell,
                  let data, let beforeData else { return }
            cell.$action
                .dropFirst()
                .sink { action in
                    onAction(action)
                }
                .store(in: &cell.cancellables)
            cell.configure(before: beforeData, after: data)
        }
    }
}
