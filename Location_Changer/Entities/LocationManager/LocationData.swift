import Foundation
import CoreLocation

enum LocationAuthorizationStatus {
    case notDetermined
    case denied
    case restricted
    case authorizedWhenInUse
    case authorizedAlways
}

extension LocationAuthorizationStatus {
    init(from status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .authorizedWhenInUse: self = .authorizedWhenInUse
        case .authorizedAlways: self = .authorizedAlways
        @unknown default: self = .denied
        }
    }
}

enum LocationError: Error {
    case notAuthorized
    case locationNotFound
}

enum LoaderState {
    case idle
    case loading
    case authorization(LocationAuthorizationStatus)
    case error(String)
    case locationDenied
    case apiError(String)
    case completed(AllNecessaryData)
}
