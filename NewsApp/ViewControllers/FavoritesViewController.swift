import UIKit
import LocalAuthentication

class FavoritesViewController: UIViewController {

    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var favoritesTableView: UITableView!
    @IBOutlet private weak var passwordButton: UIButton!
    
    private let noteView = NoteView.instanceFromNib()
    private let passwordView = PasswordView.instanceFromNib()
    private let favorites = FavoritesManager.shared
    
    //MARK: - Main functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        addViews()
        registerTableViewCell()
    }
    
    //MARK: - IBActions

    @IBAction private func backButtonIsPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func passwordButtonIsPressed(_ sender: UIButton) {
        if favorites.touchIDisActive || favorites.userPassword.count == 4 {
            showResetPasswordAlert()
        } else {
            showAddPasswordAlert()
            passwordView.passwordOption = .create
        }
    }
    
    //MARK: - Flow functions
    
    private func configUI() {
        configButton(backButton, with: "xmark", pointSize: 24)
        configButton(passwordButton, with: "key.fill", pointSize: 20)
    }
    
    private func addViews() {
        addNoteView()
        addPasswordView()
    }
    
    private func configButton(_ button: UIButton, with name: String, pointSize: CGFloat) {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .light, scale: .large)
        let buttonImage = UIImage(systemName: name, withConfiguration: configuration)!.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(buttonImage, for: .normal)
    }
    
    private func registerTableViewCell() {
        let nib = UINib(nibName: "NewsItemTableViewCell", bundle: nil)
        favoritesTableView.register(nib, forCellReuseIdentifier: "NewsItemTableViewCell")
    }
    
    private func addNoteView() {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        var squareSide = width/1.5
        if height < width {
            squareSide = height/1.5
        }
        self.view.addSubview(noteView)
        configNoteView()
        addConstraintsToNoteView(sideSize: squareSide)
    }

    private func configNoteView() {
        noteView.alpha = 0
        noteView.layer.cornerRadius = 10
        noteView.layer.borderWidth = 1
        noteView.layer.borderColor = UIColor.black.cgColor
        noteView.noteAnimationDelegate = self
    }

    private func addConstraintsToNoteView(sideSize: CGFloat) {
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteView.widthAnchor.constraint(equalToConstant: sideSize).isActive = true
        noteView.heightAnchor.constraint(equalToConstant: sideSize).isActive = true
        noteView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        noteView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -60).isActive = true
    }
    
    private func addPasswordView() {
        configPasswordView()
        self.view.addSubview(passwordView)
        addConstraintsTo(passwordView)
    }
    
    private func configPasswordView() {
        passwordView.alpha = 0
        passwordView.passwordAnimationDelegate = self
        passwordView.viewController = self
        passwordView.configUI()
    }
    
    private func addConstraintsTo(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    private func showAddPasswordAlert() {
        let alertController = UIAlertController(title: nil, message: "Do you want to add a password to open your notes?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.addPasswordAction()
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(no)
        alertController.addAction(yes)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func addPasswordAction() {
        self.showPasswordField(itemIndex: nil, with: "Create password")
        self.passwordView.passwordOption = .create
    }
    
    private func showResetPasswordAlert() {
        let alertController = UIAlertController(title: nil, message: "Do you want to reset a password or remove it?", preferredStyle: .actionSheet)
        let reset = UIAlertAction(title: "Reset password", style: .default) { (_) in
            self.resetAlertAction(option: .reset)
        }
        let remove = UIAlertAction(title: "Remove password", style: .default) { (_) in
            self.resetAlertAction(option: .remove)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(reset)
        alertController.addAction(remove)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func resetAlertAction(option: PasswordOption) {
        self.showPasswordField(itemIndex: nil, with: "Re-enter password")
        self.passwordView.passwordOption = option
    }
    
    private func showPasswordField(itemIndex: Int?, with text: String) {
        passwordView.setUpPasswordView(with: text)
        passwordView.itemIndex = itemIndex
        animatePasswordView(isFresh: true)
    }
    
    private func useBiometricCheck(for itemIndex: Int) {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Use \(String(describing: biometricItem)) to open your note") { (isSuccessful, error) in
                if isSuccessful {
                    DispatchQueue.main.async {
                        self.setUpShowNoteAction(with: itemIndex)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showPasswordField(itemIndex: itemIndex, with: "Enter password")
                        self.passwordView.passwordOption = .check
                    }
                }
            }
        }
    }
    
    private func biometricItem() -> String {
        switch BiometricCheck.biometricType() {
        case .face:
            return "Face ID"
        case .touch:
            return "Touch ID"
        case .none:
            return ""
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsItemTableViewCell", for: indexPath) as? NewsItemTableViewCell else {
            return UITableViewCell()
        }
        let model = favorites.favorites[indexPath.row]
        cell.configCell(with: model)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        let removeFromFavoritesAction = UIContextualAction(style: .destructive, title: nil) { (action, view, completionHandler) in
            let item = self.favorites.favorites[indexPath.row]
            self.favorites.favoritesAction(for: item)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        removeFromFavoritesAction.image = UIImage(systemName: "trash",withConfiguration: configuration)
        return UISwipeActionsConfiguration(actions: [removeFromFavoritesAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        let showNoteAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            if self.favorites.userPassword == "" {
                self.setUpShowNoteAction(with: indexPath.row)
            } else {
                if self.favorites.touchIDisActive {
                    self.useBiometricCheck(for: indexPath.row)
                } else {
                    self.showPasswordField(itemIndex: indexPath.row, with: "Enter a password")
                    self.passwordView.passwordOption = .check
                }
            }
            completionHandler(true)
        }
        showNoteAction.image = UIImage(systemName: "square.and.pencil",withConfiguration: configuration)!.withTintColor(.black, renderingMode: .alwaysOriginal)
        showNoteAction.backgroundColor = .yellow
        return UISwipeActionsConfiguration(actions: [showNoteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = favorites.favorites[indexPath.row]
        if let viewController = self.storyboard?.instantiateViewController(identifier: "NewsViewController") as? NewsViewController {
            viewController.newsItem = model
            viewController.tableViewDelegate = self
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
}

//MARK: - TableViewDelegate

extension FavoritesViewController: TableViewDelegate {
    
    func refreshTableView() {
        favoritesTableView.reloadData()
    }
    
}

//MARK: - NoteAnimationDelegate

extension FavoritesViewController: NoteAnimationDelegate {
    
    func animateNote(isActive: Bool) {
        var alpha:CGFloat = 1
        enableUserInteraction(false)
        if isActive {
            enableUserInteraction(true)
            alpha = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.noteView.alpha = alpha
        }
    }
    
    private func enableUserInteraction(_ isEnabled: Bool) {
        favoritesTableView.isUserInteractionEnabled = isEnabled
        passwordButton.isUserInteractionEnabled = isEnabled
        backButton.isUserInteractionEnabled = isEnabled
    }
    
}

//MARK: - PasswordAnimationDelegate

extension FavoritesViewController: PasswordAnimationDelegate {
    
    func animatePasswordView(isFresh: Bool) {
        var alpha:CGFloat = 0
        if isFresh {
            alpha = 1
        }
        UIView.animate(withDuration: 0.3) {
            self.passwordView.alpha = alpha
        }
    }
    
    func setUpShowNoteAction(with index: Int) {
        let item = favorites.favorites[index]
        self.noteView.newsItem = item
        self.animateNote(isActive: false)
        guard let text = item.note else {
            self.noteView.fillInTextView(with: "")
            return
        }
        self.noteView.fillInTextView(with: text)
    }
    
}
