import UIKit

class PasswordView: UIView {
    
    @IBOutlet private weak var deleteLastDigitButton: UIButton!
    @IBOutlet private var digitButtons: [UIButton]!
    @IBOutlet private var passwordLabels: [UILabel]!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var informationLabel: UILabel!
    
    var passwordAnimationDelegate:PasswordAnimationDelegate?
    var viewController:UIViewController?
    var itemIndex:Int?
    var passwordOption:PasswordOption?
    private var currentPassword = ""
    private let labelTextService = LabelTextService()
    private let favorites = FavoritesManager.shared
    
    class func instanceFromNib() -> PasswordView {
        return UINib(nibName: "PasswordView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PasswordView
    }
    
    //MARK: - IBActions
    
    @IBAction private func digitButtonIsPressed(_ sender: UIButton) {
        let digit = "\(sender.tag)"
        if currentPassword.count < 4 {
            appendDigit(digit)
        }
        showNoteIfAvailable()
    }
    
    @IBAction private func deleteLastDigitButtonIsPressed(_ sender: UIButton) {
        deleteDigit()
    }
    
    @IBAction private func actionButtonIsPressed(_ sender: UIButton) {
        guard let passwordOption = passwordOption, currentPassword.count == 4 else {
            if let passwordDelegate = passwordAnimationDelegate {
                passwordDelegate.animatePasswordView(isFresh: false)
            }
            return
        }
        checkAction(with: passwordOption)
    }
    
    //MARK: - Flow functions
    
    private func appendDigit(_ digit: String) {
        currentPassword.append(digit)
        fillInPasswordLabelsField(with: digit)
        if currentPassword.count == 4 {
            setUpButton(actionButton, with: "checkmark", color: .green, pointSize: 25)
        }
    }
    
    private func deleteDigit() {
        if currentPassword.count > 0 {
            fillInPasswordLabelsField(with: "-")
            currentPassword.removeLast()
        }
        if currentPassword.count <= 4 && currentPassword.count != 0 {
            setUpButton(actionButton, with: "xmark", color: .blue, pointSize: 25)
        }
    }
    
    private func checkAction(with option: PasswordOption) {
        guard let passwordDelegate = passwordAnimationDelegate else {
            return
        }
        switch option {
        case .create:
            createPassword(delegate: passwordDelegate)
        case .check:
            checkPassword(delegate: passwordDelegate)
        case .remove:
            removePassword(delegate: passwordDelegate)
        case .reset:
            removePassword(delegate: passwordDelegate)
        }
    }
    
    private func createPassword(delegate: PasswordAnimationDelegate) {
        favorites.savePassword(currentPassword)
        delegate.animatePasswordView(isFresh: false)
        showAlert(with: "Password has created!")
    }
    
    private func checkPassword(delegate: PasswordAnimationDelegate) {
        if currentPassword == favorites.userPassword {
            delegate.animatePasswordView(isFresh: false)
            if let itemIndex = itemIndex {
                delegate.setUpShowNoteAction(with: itemIndex)
            }
        } else {
            failedPasswordAlert()
        }
    }
    
    private func removePassword(delegate: PasswordAnimationDelegate) {
        if currentPassword == favorites.userPassword {
            favorites.savePassword("")
            favorites.saveTouchIDSettings(false)
            delegate.animatePasswordView(isFresh: false)
            nextStepAfterRemovingPassword()
        } else  {
            failedPasswordAlert()
        }
    }
    
    private func failedPasswordAlert() {
        showAlert(with: "Enter a correct password!")
        setUpButton(actionButton, with: "xmark", color: .blue, pointSize: 25)
        cleanPasswordField()
    }
    
    private func nextStepAfterRemovingPassword() {
        if passwordOption == .remove {
            showAlert(with: "Password has been removed")
        } else {
            resetAction()
        }
    }
    
    private func showNoteIfAvailable() {
        if currentPassword.count == 4 && passwordOption == .check {
            guard let delegate = passwordAnimationDelegate else {
                return
            }
            checkPassword(delegate: delegate)
        }
    }
    
    private func fillInPasswordLabelsField(with charachter: String) {
        for element in passwordLabels {
            if currentPassword.count == element.tag {
                element.text = "\(charachter)"
            }
        }
    }
    
    private func showAlert(with text: String) {
        guard let viewController = viewController else {
            return
        }
        let alertController = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            if self.passwordOption == .create && BiometricCheck.biometricType() != .none {
                self.showBiometricAlert(with: self.labelTextService.biometricalAlertMessage())
            }
        }
        alertController.addAction(ok)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func showBiometricAlert(with message: String) {
        guard let viewController = viewController else {
            return
        }
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.favorites.saveTouchIDSettings(true)
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(yes)
        alertController.addAction(no)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func resetAction() {
        guard let delegate = passwordAnimationDelegate else {
            return
        }
        setUpPasswordView(with: "Enter a new password")
        delegate.animatePasswordView(isFresh: true)
        passwordOption = .create
    }
    
    func setUpPasswordView(with message: String) {
        informationLabel.text = message
        cleanPasswordField()
        setUpButton(actionButton, with: "xmark", color: .blue, pointSize: 25)
    }
    
    private func cleanPasswordField() {
        currentPassword = ""
        for element in passwordLabels {
            element.text = "-"
        }
    }
    
    private func setUpButton(_ button: UIButton, with imageName: String, color: UIColor, pointSize: CGFloat) {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .light, scale: .large)
        let buttonImage = UIImage(systemName: imageName, withConfiguration: configuration)!.withTintColor(color, renderingMode: .alwaysOriginal)
        button.setImage(buttonImage, for: .normal)
    }
    
    func configUI() {
        let color = UIColor(red: 213/255, green: 0/255, blue: 0/255, alpha: 1)
        setUpButton(deleteLastDigitButton, with: "delete.left", color: color, pointSize: 30)
    }
    
}
