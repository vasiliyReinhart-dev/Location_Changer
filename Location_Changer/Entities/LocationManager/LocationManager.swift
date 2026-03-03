
import UIKit
import CoreLocation
import MapKit

final class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    private var authorizationContinuation: CheckedContinuation<LocationAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorizationIfNeeded() async -> LocationAuthorizationStatus {
        let current = LocationAuthorizationStatus(from: locationManager.authorizationStatus)
        guard current == .notDetermined else {
            return current
        }
        if authorizationContinuation != nil {
            return current
        }
        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func getCurrentLocation() async throws -> CLLocation {
        let status = LocationAuthorizationStatus(from: locationManager.authorizationStatus)
        
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw LocationError.notAuthorized
        }
        if locationContinuation != nil {
            locationManager.stopUpdatingLocation()
            locationContinuation?.resume(throwing: CancellationError())
            locationContinuation = nil
        }
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.startUpdatingLocation()
        }
    }
    
    func reverseGeocode(_ location: CLLocation) async throws -> CLPlacemark? {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        return placemarks.first
    }
    func createMapScreenshot(mapView: MKMapView,
                             completion: @escaping (UIImage?) -> Void) {
        let options = MKMapSnapshotter.Options()
        options.region = mapView.region
        options.size = mapView.bounds.size
        options.scale = UIScreen.main.scale
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil)
                return
            }
            let image = snapshot.image
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: .zero)
            let point = snapshot.point(for: mapView.centerCoordinate)
            
            if let customIcon = UIImage(named: "place_tag") {
                let iconRect = CGRect(x: point.x - customIcon.size.width / 2,
                                      y: point.y - customIcon.size.height,
                                      width: customIcon.size.width,
                                      height: customIcon.size.height)
                customIcon.draw(in: iconRect)
            }
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completion(finalImage)
        }
    }
    func makePlaceMark(_ location: CLLocation) async -> CLPlacemark? {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first
        } catch {
            print("Ошибка геокодирования: \(error.localizedDescription)")
            return nil
        }
    }
//    func shareLocation() {
//        let address = adressTitle.text ?? ""
//        let coordsText = "\(String(localized: "Coordinates:")) \(coordinate)"
//        let cleanCoordinates = coordinate.replacingOccurrences(of: " ", with: "")
//        let mapUrlString = "https://maps.apple.com/?ll=\(cleanCoordinates)&q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
//        guard let url = URL(string: mapUrlString) else { return }
//        let shareText = "\(address)\n\(coordsText)"
//        let itemsToShare: [Any] = [shareText, url]
//        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
//        if let popover = activityViewController.popoverPresentationController {
//            activityViewController.modalPresentationStyle = .popover
//            popover.sourceView = self.view
//            popover.sourceRect = CGRect(x: self.view.bounds.midX,
//                                        y: self.view.bounds.midY,
//                                        width: 0,
//                                        height: 0)
//            popover.permittedArrowDirections = []
//        }
//        
//        self.present(activityViewController, animated: true, completion: nil)
//    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = LocationAuthorizationStatus(from: manager.authorizationStatus)
        guard status != .notDetermined else { return }
        if let continuation = authorizationContinuation {
            continuation.resume(returning: status)
            authorizationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        if let continuation = locationContinuation {
            continuation.resume(returning: location)
            locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        if let continuation = locationContinuation {
            continuation.resume(throwing: error)
            locationContinuation = nil
        }
    }
}
