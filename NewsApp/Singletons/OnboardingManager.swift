import UIKit

class OnboardingManager {
    
    let onboardingImages = [UIImage(named: "onboarding1"),
                            UIImage(named: "onboarding2"),
                            UIImage(named: "onboarding3"),
                            UIImage(named: "onboarding4"),
                            UIImage(named: "onboarding5")]
    
    static let shared = OnboardingManager()
    init () {}
    
    func newUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "newUser")
    }
    
    func setNotNewUser() {
        UserDefaults.standard.set(true, forKey: "newUser")
    }
    
}
