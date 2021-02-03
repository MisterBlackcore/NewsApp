import UIKit

class SettingsViewXIB: UIView {
    
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var refreshCategoryButton: UIButton!
    @IBOutlet private weak var categoryButton: UIButton!
    @IBOutlet private weak var refreshCountryButton: UIButton!
    @IBOutlet private weak var countryButton: UIButton!
    @IBOutlet private weak var refreshSourceButton: UIButton!
    @IBOutlet private weak var sourceButton: UIButton!
    @IBOutlet private weak var hideSettingsViewButton: UIButton!
    @IBOutlet private weak var topHeadlinesSwitcher: UISwitch!
    @IBOutlet private weak var refreshButton: UIButton!
    @IBOutlet private weak var countryAndCategoryViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sourceViewHeightConstraint: NSLayoutConstraint!
    
    var animationDelegate:AnimationHelperDelegate?
    var networkDelegate:NetworkDelegate?
    var searchBarDelegate:SearchBarDelegate?
    var widthConstraint:NSLayoutConstraint?
    var refreshed = false
    
    private let newsApi = NetworkManager.shared.newsApi
    private let optionsTableView = UITableView()
    private let tableViewService = TableViewService()
    private let labelTextService = LabelTextService()
    
    class func instanceFromNib() -> SettingsViewXIB {
        return UINib(nibName: "SettingsViewXIB", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SettingsViewXIB
    }
    
    //MARK: - IBActions
    
    @IBAction private func hideSettingsViewButtonIsPressed(_ sender: UIButton) {
        if self.subviews.contains(optionsTableView) {
            hideTableView()
        } else {
            refreshNewsFeedViewController()
        }
    }
    
    @IBAction private func topHeadlinesSwitcherIsSelected(_ sender: UISwitch) {
        refreshed = true
        if sender.isOn {
            newsApi.currentEndpoint = newsApi.topHeadlinesEndpoint
            animateCountriesAndCategoriesView(isHidden: true)
        } else {
            newsApi.currentEndpoint = newsApi.everythingEndpoint
            animateCountriesAndCategoriesView(isHidden: false)
            animateSourceView(isHidden: true)
        }
        newsApi.refreshAllParameters()
    }
    
    @IBAction private func chooseTableViewOption(_ sender: UIButton) {
        guard let option = setCategory(with: sender.tag) else {
            return
        }
        setUpTableView(with: option, button: sender)
    }
    
    @IBAction private func chooseRefreshOption(_ sender: UIButton) {
        guard let option = setCategory(with: sender.tag) else {
            return
        }
        refreshed = true
        if sender.tag == 1 && topHeadlinesSwitcher.isOn {
            animateCountriesAndCategoriesView(isHidden: true)
        } else {
            if newsApi.countryCode == nil || newsApi.category == nil {
                animateSourceView(isHidden: true)
            }
        }
        refreshButtonSelected(option: option)
    }
    
    @IBAction private func refreshButtonIsPressed(_ sender: UIButton) {
        refreshed = true
        refreshAllButtons()
        animateSourceView(isHidden: true)
    }
    
    //MARK: - Flow functions
    
    func configUI() {
        configHideSettingsViewButton()
        configRefreshButton()
        countryButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sourceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        categoryButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private func configHideSettingsViewButton() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light, scale: .large)
        let buttonImage = UIImage(systemName: "arrow.left", withConfiguration: configuration)!.withTintColor(.white, renderingMode: .alwaysOriginal)
        hideSettingsViewButton.setImage(buttonImage, for: .normal)
    }
    
    private func configRefreshButton() {
        refreshButton.layer.masksToBounds = false
        refreshButton.layer.cornerRadius = 5
        refreshButton.backgroundColor = UIColor(red: 48/255, green: 63/255, blue: 159/255, alpha: 1)
    }
    
    func addUserCountry(_ country: CountryModel) {
        tableViewService.addUserCountry(country)
    }
    
    private func refreshAllButtons() {
        refreshOptionButtons()
        topHeadlinesSwitcher.setOn(true, animated: true)
        topHeadlinesSwitcherIsSelected(topHeadlinesSwitcher)
    }
    
    private func refreshOptionButtons() {
        refreshButtonSelected(option: .categories)
        refreshButtonSelected(option: .countries)
        refreshButtonSelected(option: .sources)
    }
    
    private func setUpTableView(with option: SettingsOption, button: UIButton) {
        addTableView(option: option)
        tableViewService.chosenOptionButton = button
    }
    
    private func addTableView(option: SettingsOption) {
        self.addSubview(optionsTableView)
        configTableView()
        configTableViewService(with: option)
        configSettingsViewUI(option: option)
        animateOptionsTableView()
        optionsTableView.reloadData()
    }
    
    private func configTableView() {
        optionsTableView.isHidden = true
        optionsTableView.alpha = 0
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.separatorColor = .black
        optionsTableView.tableFooterView = UIView()
        configCellForTableView()
        addConstraintsToOptionsTableView()
    }
    
    private func configCellForTableView() {
        let nib = UINib(nibName: "OptionsTableViewCell", bundle: nil)
        optionsTableView.register(nib, forCellReuseIdentifier: "OptionsTableViewCell")
    }
    
    private func addConstraintsToOptionsTableView() {
        optionsTableView.translatesAutoresizingMaskIntoConstraints = false
        optionsTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        optionsTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        optionsTableView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        optionsTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }
    
    private func configTableViewService(with option: SettingsOption) {
        tableViewService.currentOption = option
        tableViewService.chosenOptionRefreshButton = returnRefreshButton(option: option)
        tableViewService.xibAnimationDelegate = self
    }
    
    private func configSettingsViewUI(option: SettingsOption?) {
        stateLabel.text = labelTextService.returnText(option: option)
    }
    
    private func animateOptionsTableView() {
        if optionsTableView.isHidden {
            optionsTableView.isHidden = false
            animateTableView(with: 1)
        } else {
            animateTableView(with: 0)
        }
    }
    
    private func animateTableView(with alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.optionsTableView.alpha = alpha
        } completion: { (_) in
            if alpha == 0 {
                self.optionsTableView.isHidden = true
                self.optionsTableView.removeFromSuperview()
            }
        }
    }
    
    private func hideTableView() {
        animateOptionsTableView()
        configSettingsViewUI(option: nil)
    }
    
    private func hideSettingsViewXIB() {
        if let animationDelegate = animationDelegate {
            animationDelegate.animateWidthOfSettingsView(multiplier: 0, blurViewAlpha: 0)
        }
    }
    
    func refreshNewsFeedViewController() {
        hideSettingsViewXIB()
        if let networkDelegate = networkDelegate, let searchBarDelegate = searchBarDelegate {
            if !refreshed {
                return
            }
            searchBarDelegate.hideSearchBar()
            newsApi.addApiParameters()
            networkDelegate.getNewsFeed(isFresh: true)
        }
    }
    
    private func refreshButtonSelected(option: SettingsOption) {
        switch option {
        case .categories:
            newsApi.category = nil
            refresh(categoryButton, with: "Choose category", for: refreshCategoryButton)
        case .countries:
            newsApi.countryCode = nil
            refresh(countryButton, with: "Choose country", for: refreshCountryButton)
        case .sources:
            newsApi.source = nil
            refresh(sourceButton, with: "Choose source", for: refreshSourceButton)
        }
    }
    
    private func refresh(_ button: UIButton, with title: String, for refreshButton: UIButton) {
        button.setTitle(title, for: .normal)
        hideRefreshButton(refreshButton)
    }
    
    private func hideRefreshButton(_ button: UIButton) {
        let systemImage = UIImage(systemName: "")
        button.setImage(systemImage, for: .normal)
        button.isHidden = true
    }

    private func setCategory(with tag: Int) -> SettingsOption? {
        switch tag {
        case 1:
            return .sources
        case 2:
            return .countries
        case 3:
            return .categories
        default:
            return nil
        }
    }
    
    private func returnRefreshButton(option: SettingsOption) -> UIButton {
        switch option {
        case .countries:
            return refreshCountryButton
        case .categories:
            return refreshCategoryButton
        case .sources:
            return refreshSourceButton
        }
    }
    
    func refreshSources() {
        tableViewService.loadSources()
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension SettingsViewXIB: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewService.numberOfComponents()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = optionsTableView.dequeueReusableCell(withIdentifier: "OptionsTableViewCell", for: indexPath) as? OptionsTableViewCell else {
            return UITableViewCell()
        }
        let name = tableViewService.titleForRow(indexPath.row)
        cell.configCellWith(name: name)
        configCellUI(cell)
        return cell
    }
    
    private func configCellUI(_ cell: UITableViewCell) {
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewService.addParameter(row: indexPath.row, in: newsApi)
        refreshed = true
        hideTableView()
    }
    
}

//MARK: - XIBAnimtionDelegate

extension SettingsViewXIB: XIBAnimtionDelegate {
    
    func animateSourceView(isHidden: Bool) {
        var height:CGFloat = 0
        if isHidden {
            sourceButton.setTitle("Choose source", for: .normal)
            hideRefreshButton(refreshSourceButton)
            height = 80
        }
        animateViewConstraint(sourceViewHeightConstraint, withHeight: height)
    }
    
    func animateCountriesAndCategoriesView(isHidden: Bool) {
        var height:CGFloat = 0
        if isHidden {
            categoryButton.setTitle("Choose category", for: .normal)
            hideRefreshButton(refreshCategoryButton)
            countryButton.setTitle("Choose country", for: .normal)
            hideRefreshButton(refreshCountryButton)
            height = 120
        }
        animateViewConstraint(countryAndCategoryViewHeightConstraint, withHeight: height)
    }
    
    private func animateViewConstraint(_ constraint: NSLayoutConstraint, withHeight height: CGFloat) {
        constraint.constant = height
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
}
