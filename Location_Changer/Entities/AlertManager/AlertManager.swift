import UIKit

final class AlertManager {
    
    static let shared = AlertManager()
    
    func showError(_ vc: UIViewController,
                   message: String,
                   onRetry: @escaping () -> Void,
                   onSkip: @escaping () -> Void) {
        let alert = UIAlertController(title: String(localized: "Something went wrong"),
                                      message: "\(String(localized: "Couldn't get weather data:")) \(message)",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: String(localized: "Try again"), style: .default) { _ in onRetry() })
        alert.addAction(UIAlertAction(title: String(localized: "Continue without data"), style: .cancel) { _ in onSkip() })
        vc.present(alert, animated: true)
    }
    func showLocationDenied(_ vc: UIViewController,
                            onSettings: @escaping () -> Void,
                            onDefault: @escaping () -> Void) {
        let alert = UIAlertController(title: String(localized: "Access to geodata is prohibited"),
                                      message: String(localized: "The location is necessary for the correct operation of the map and the accuracy of the forecast. Turn it on in the settings or use the default city."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Go to Settings"), style: .default) { _ in onSettings() })
        alert.addAction(UIAlertAction(title: String(localized: "Default (New York)"), style: .default) { _ in onDefault() })
        vc.present(alert, animated: true)
    }
    func showLocationDenied(_ vc: UIViewController,
                            onSettings: @escaping () -> Void) {
        let alert = UIAlertController(title: String(localized: "Access to geodata is prohibited"),
                                      message: String(localized: "The location is necessary for the correct operation of the map and the accuracy of the forecast. Turn it on in the settings or use the default city."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Go to Settings"), style: .default) { _ in onSettings() })
        vc.present(alert, animated: true)
    }
    func showSubscriptionError(_ vc: UIViewController,
                               tryAgain: @escaping () -> Void) {
        let alert = UIAlertController(title: String(localized: "Error when performing the operation"),
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Try Again"), style: .default) { _ in tryAgain() })
        alert.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .default) { _ in })
        vc.present(alert, animated: true)
    }
    func showRestoreError(_ vc: UIViewController) {
        let alert = UIAlertController(title: String(localized: "Error when performing the operation"),
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Ok"), style: .default) { _ in })
        vc.present(alert, animated: true)
    }
    func showErrorSavePhoto(_ vc: UIViewController,
                            tryAgain: @escaping () -> Void) {
        let alert = UIAlertController(title: String(localized: "Couldn't save photo metadata"),
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Try Again"), style: .default) { _ in tryAgain() })
        alert.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .default) { _ in })
        vc.present(alert, animated: true)
    }
    func showSuccesSavePhoto(_ vc: UIViewController,
                             ok: @escaping () -> Void) {
        let alert = UIAlertController(title: String(localized: "Metadata has been updated successfully"),
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Ok"), style: .default) { _ in ok() })
        vc.present(alert, animated: true)
    }
    
    
    func openLink(_ vc: UIViewController,
                  terms: @escaping () -> Void,
                  privacy: @escaping () -> Void) {
        let alert = UIAlertController(title: String(localized: "Terms / Privacy"), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Terms Of Use"), style: .default) { _ in terms() })
        alert.addAction(UIAlertAction(title: String(localized: "Privacy Policy"), style: .default) { _ in privacy() })
        alert.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .default) { _ in })
        vc.present(alert, animated: true)
    }
}
