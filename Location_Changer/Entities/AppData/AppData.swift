import Foundation

//  com.mambaPacan.com
// vasiliydeveloper.Location-Changer
enum AppData {
    
    static var premiumAccess: Bool = UserDefaults.standard.bool(forKey: "premium_access") {
        didSet { UserDefaults.standard.setValue(premiumAccess, forKey: "premium_access") }
    }
    static var hasOnboardingCompleted: Bool = UserDefaults.standard.bool(forKey: "isAuth_SaveValue_appDAta") {
        didSet { UserDefaults.standard.setValue(hasOnboardingCompleted, forKey: "isAuth_SaveValue_appDAta") }
    }
    static var selectedGpsAccuracy: Int = UserDefaults.standard.integer(forKey: "selectedGpsAccuracy") {
        didSet { UserDefaults.standard.setValue(selectedGpsAccuracy, forKey: "selectedGpsAccuracy") }
    }
    
    static var apphud_user_id = ""
    static var email = "flaviupekurar@gmail.com"
}
