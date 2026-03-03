import UIKit
import MapKit
import Combine
import CoreLocation

struct OnboardModel {
    let backgroundImage: UIImage?
    let headerText: String
    let descriptionText: String
}

@MainActor
final class OnboadrViewModel {
    
    static let shared = OnboadrViewModel()
    private var authorizationTask: Task<Void, Never>?
    @Published private(set) var state: LoaderState = .idle
    
    private let duration = 3.0
    var didStartOnboard: (() -> Void)?
    
    var data: [OnboardModel] = [
        .init(backgroundImage: UIImage(named: "onb1"),
              headerText: String(localized: "Change GPS \nLocation"),
              descriptionText: String(localized: "Teleport your GPS anywhere in \nseconds")),
        .init(backgroundImage: UIImage(named: "onb2"),
              headerText: String(localized: "Use Any \nApp"),
              descriptionText: String(localized: "Works with maps, games, social & \ndating apps")),
        .init(backgroundImage: UIImage(named: "onb3"),
              headerText: String(localized: "Safe & \nPrivate"),
              descriptionText: String(localized: "No jailbreak. Your real location stays \nhidden"))
    ]
    
    func showLogo(_ logo: UIView) {
        logo.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5, animations: {
            logo.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { finished in
            UIView.animate(withDuration: 0.3) {
                logo.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        })
        hiddenLogo(logo)
    }
   private func hiddenLogo(_ logo: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration - 0.4) {
            UIView.animate(withDuration: 0.3, animations: {
                logo.alpha = 0.0
            }, completion: { finished in
                self.didStartOnboard?()
            })
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
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    deinit {
        authorizationTask?.cancel()
    }
}

//MARK: ________________________________________________________________________ Location Manager & Network Manager

extension OnboadrViewModel {
    
    func checkAuthorizationStatus() {
        if case .loading = state { return }
        authorizationTask?.cancel()
        state = .loading
        authorizationTask = Task {
            let status = await LocationManager.shared.requestAuthorizationIfNeeded()
            guard !Task.isCancelled else { return }
            state = .authorization(status)
            switch status {
            case .denied:
                state = .locationDenied
            case .authorizedWhenInUse, .authorizedAlways, .restricted:
                await getLocationAndWeather()
            default: break
            }
        }
    }
    func defaultLocation() {
        authorizationTask?.cancel()
        authorizationTask = Task {
            await getWeather(placemark: createDefaultPlacemark())
        }
    }
    private func getLocationAndWeather() async {
        do {
            try Task.checkCancellation()
            let location = try await LocationManager.shared.getCurrentLocation()
            let placemark = try await LocationManager.shared.reverseGeocode(location)
            printPlacemark(placemark)
            await getWeather(placemark: placemark)
        } catch {
            guard !(error is CancellationError) else { return }
            
            let fallback = createDefaultPlacemark()
            printPlacemark(fallback)
            state = .error(error.localizedDescription)
            await getWeather(placemark: fallback)
        }
    }
    private func getWeather(placemark: CLPlacemark?) async {
        let coordinate: CLLocationCoordinate2D
        if let location = placemark?.location {
            coordinate = location.coordinate
        } else {
            coordinate = defaultCoordinate()
        }
        do {
            let weather = try await NetworkManager.shared.fetchWeatherData(latitude: coordinate.latitude,
                                                                           longitude: coordinate.longitude)
            let data = AllNecessaryData(weather: weather,
                                        placemark: placemark)
            state = .completed(data)
        } catch let apiError as WeatherAPIError {
            state = .apiError(apiError.localizedDescription)
        } catch {
            guard !(error is CancellationError) else { return }
            state = .error(error.localizedDescription)
        }
    }
    private func printPlacemark(_ placemark: CLPlacemark?) {
        if let placemark = placemark {
            let city = placemark.locality
            let country = placemark.country
            let street = placemark.thoroughfare
            print("страна: \(country ?? ""), город: \(city ?? ""), улица: \(street ?? "")")
        }
    }
    private func createDefaultPlacemark() -> CLPlacemark {
        let addressDict: [String: Any] = [
            "City": "New York",
            "Country": "USA",
            "Street": "Broadway"
        ]
        return MKPlacemark(coordinate: defaultCoordinate(),
                           addressDictionary: addressDict)
    }
    private func defaultCoordinate() -> CLLocationCoordinate2D {
        // Нью-Йорк, центр Манхэттена
        return CLLocationCoordinate2D(latitude: 40.712776,
                                      longitude: -74.005974)
    }
}
