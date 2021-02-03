import UIKit

struct LabelTextService {
    
    private let settings = "Settings"
    private let categories = "Categories"
    private let countries = "Countries"
    private let sources = "Sources"
    
    //MARK: - Flow functions
    
    func returnText(option: SettingsOption?) -> String {
        switch option {
        case .categories:
            return categories
        case .countries:
            return countries
        case .sources:
            return sources
        case .none:
            return settings
        }
    }
    
    func biometricalAlertMessage() -> String {
        switch BiometricCheck.biometricType() {
        case .face:
            return "Do you want to add Face ID?"
        case .touch:
            return "Do you want to add Touch ID?"
        case .none:
            return ""
        }
    }

}
