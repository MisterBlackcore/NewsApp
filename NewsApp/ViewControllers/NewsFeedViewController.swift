import UIKit
import CoreLocation

class NewsFeedViewController: UIViewController {

    @IBOutlet private weak var keyWordSearchBar: UISearchBar!
    @IBOutlet private weak var newsFeedTableView: UITableView!
    @IBOutlet private weak var showSettingsMenuButton: UIButton!
    @IBOutlet private weak var favoritesButton: UIButton!
    
    private var showSettingsMenuGestureRecogniser = UITapGestureRecognizer()
    private var hideSettingsMenuGestureRecogniser = UITapGestureRecognizer()
    private var refreshControl = UIRefreshControl()
    private var isLoaded = false
    private var newsFeed = [NewsItemModel]()
    private var newsPagesNumber:Int?
    private lazy var activityIndicator = LoadMore(scrollView: newsFeedTableView, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 60)
    
    private let locationManager = CLLocationManager()
    private let settingsView = SettingsViewXIB.instanceFromNib()
    private let blurView = UIVisualEffectView()
    private let newsApi = NetworkManager.shared.newsApi
    
    //MARK: - Main functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        addViews()
        configUI()
        setUpLocationManager()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if OnboardingManager.shared.newUser() {
            if let viewController = self.storyboard?.instantiateViewController(identifier: "OnboardingViewController") as? OnboardingViewController {
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - IBActions
    
    @IBAction private func showSettingsMenuButtonIsPressed(_ sender: UIButton) {
        if blurView.alpha == 0 {
            settingsView.refreshed = false
            animateWidthOfSettingsView(multiplier: 0.75, blurViewAlpha: 1)
        } else {
            settingsView.refreshNewsFeedViewController()
        }
        hideSearchBarInteraction()
    }
    
    @IBAction private func favoritesButtonIsPressed(_ sender: UIButton) {
        if let viewController = self.storyboard?.instantiateViewController(identifier: "FavoritesViewController") as? FavoritesViewController {
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction private func refresh(_ sender: AnyObject) {
        getNewsFeed(isFresh: true)
    }
    
    //MARK: - Flow functions
    
    private func configTableView() {
        addTapGestureRecogniserOnTableView()
        registerTableViewCell()
        NetworkManager.shared.tableViewDelegate = self
    }
    
    private func addViews() {
        addSettingsView()
        addBlurView()
    }
    
    private func configUI() {
        addTapGestureRecogniserOnBlurView()
        configFavoritesButton()
        configRefreshControl()
    }
    
    private func addTapGestureRecogniserOnTableView() {
        showSettingsMenuGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(showSettingsMenuButtonIsPressed(_:)))
        newsFeedTableView.addGestureRecognizer(showSettingsMenuGestureRecogniser)
    }
    
    private func addTapGestureRecogniserOnBlurView() {
        hideSettingsMenuGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(showSettingsMenuButtonIsPressed(_:)))
        blurView.addGestureRecognizer(hideSettingsMenuGestureRecogniser)
    }
    
    private func configFavoritesButton() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .thin, scale: .large)
        let buttonImage = UIImage(systemName: "star", withConfiguration: configuration)!.withTintColor(.white, renderingMode: .alwaysOriginal)
        favoritesButton.setImage(buttonImage, for: .normal)
    }
    
    private func configRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        newsFeedTableView.addSubview(refreshControl)
    }
    
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    private func addSettingsView() {
        self.view.addSubview(settingsView)
        setUpSettingsViewDelegates()
        settingsView.configUI()
        addConstraintsToSettingsView()
    }
    
    private func setUpSettingsViewDelegates() {
        settingsView.animationDelegate = self
        settingsView.networkDelegate = self
        settingsView.searchBarDelegate = self
    }
    
    private func addConstraintsToSettingsView() {
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        settingsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        settingsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        settingsView.widthConstraint = settingsView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0)
        settingsView.widthConstraint?.isActive = true
    }
    
    private func addBlurView() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        blurView.effect = blurEffect
        blurView.alpha = 0
        self.view.addSubview(blurView)
        addConstraintsToBlurView()
    }
    
    private func addConstraintsToBlurView() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    private func registerTableViewCell() {
        let nib = UINib(nibName: "NewsItemTableViewCell", bundle: nil)
        newsFeedTableView.register(nib, forCellReuseIdentifier: "NewsItemTableViewCell")
    }

}

//MARK: - UITableViewDataSource

extension NewsFeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setUpInteractionWithTable()
        return newsFeed.count
    }
    
    private func setUpInteractionWithTable() {
        if newsFeed.count == 0 {
            showSettingsMenuGestureRecogniser.isEnabled = true
        } else {
            showSettingsMenuGestureRecogniser.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = newsFeedTableView.dequeueReusableCell(withIdentifier: "NewsItemTableViewCell", for: indexPath) as? NewsItemTableViewCell else {
            return UITableViewCell()
        }
        let model = newsFeed[indexPath.row]
        cell.configCell(with: model)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.newsFeed[indexPath.row]
        let addToFavoritesAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            FavoritesManager.shared.favoritesAction(for: item)
            completionHandler(true)
        }
        configureAction(addToFavoritesAction, item: item)
        return UISwipeActionsConfiguration(actions: [addToFavoritesAction])
    }
    
    private func configureAction(_ action: UIContextualAction, item: NewsItemModel) {
        action.backgroundColor = UIColor(red: 169/255, green: 130/255, blue: 207/255, alpha: 1)
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin, scale: .large)
        if FavoritesManager.shared.inFavorites(item) {
            action.image = UIImage(systemName: "star.fill", withConfiguration: configuration)!.withTintColor(.black, renderingMode: .alwaysOriginal)
        } else {
            action.image = UIImage(systemName: "star", withConfiguration: configuration)!.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        action.image?.withRenderingMode(.alwaysTemplate)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = newsFeed[indexPath.row]
        if let viewController = self.storyboard?.instantiateViewController(identifier: "NewsViewController") as? NewsViewController {
            if let source = model.source, let sourceName = source.name {
                viewController.newsSourceName = sourceName
            }
            viewController.newsItem = model
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
}

//MARK: - UITableViewDelegate

extension NewsFeedViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadNewData()
    }
    
    private func loadNewData() {
        activityIndicator.start {
            DispatchQueue.global().async {
                sleep(3)
                DispatchQueue.main.async { [weak self] in
                    if self?.newsLeft() == true {
                        self?.getNewsFeed(isFresh: false)
                    }
                    self?.activityIndicator.stop()
                }
            }
        }
    }
    
    private func newsLeft() -> Bool {
        if newsFeed.count%20 != 0 {
            return false
        } else {
            let pageNumber = newsFeed.count/20 + 1
            newsApi.refreshPage(pageNumber)
            return true
        }
    }
    
}

//MARK: - CLLocationManagerDelegate

extension NewsFeedViewController: CLLocationManagerDelegate {
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let geoCoder = CLGeocoder()
            let englishLocale = Locale(identifier: "en-US")
            geoCoder.reverseGeocodeLocation(location, preferredLocale: englishLocale) { (placemarks, error) in
                if !self.isLoaded {
                    if let countryCode = placemarks?.first?.isoCountryCode {
                        self.setUpCountryCode(with: countryCode)
                    }
                    self.loadData()
                }
            }
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if !self.isLoaded {
            if let regionCode = Locale.current.regionCode {
                setUpCountryCode(with: regionCode)
            }
            loadData()
        }
    }
    
    private func setUpCountryCode(with countryCode: String) {
        newsApi.countryCode = countryCode
        settingsView.addUserCountry(CountryModel(name: "Your country", code: countryCode))
    }
    
    private func loadData() {
        newsApi.addApiParameters()
        getNewsFeed(isFresh: false)
        newsApi.countryCode = nil
        isLoaded = true
    }
                                        
}

//MARK: - UISearchBarDelegate

extension NewsFeedViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideKeyboardOnSearchBar()
        newsApi.addApiParameters()
        self.getNewsFeed(isFresh: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        hideKeyboardOnSearchBar()
    }
    
    private func hideKeyboardOnSearchBar() {
        newsApi.searchWord = keyWordSearchBar.text?.trimmingCharacters(in: .whitespaces)
        hideSearchBarInteraction()
    }
    
    private func hideSearchBarInteraction() {
        keyWordSearchBar.showsCancelButton = false
        keyWordSearchBar.resignFirstResponder()
    }
}

//MARK: - AnimationDelegate

extension NewsFeedViewController: AnimationHelperDelegate {
    
    func animateWidthOfSettingsView(multiplier: CGFloat, blurViewAlpha: CGFloat) {
        self.view.bringSubviewToFront(settingsView)
        let newWidthConstraint = settingsView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: multiplier)
        guard let widthConstraint = settingsView.widthConstraint else {
            return
        }
        self.view.removeConstraint(widthConstraint)
        self.view.addConstraint(newWidthConstraint)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.blurView.alpha = blurViewAlpha
            self.settingsView.widthConstraint = newWidthConstraint
        }
    }
    
}

//MARK: - NetworkDelegate

extension NewsFeedViewController: NetworkDelegate {
    
    func getNewsFeed(isFresh: Bool) {
        if !InternetConnectionService.connectedToInternet() {
            setUpNotConnectedTableView()
            return
        }
        setUpTableView(isFresh: isFresh)
        NetworkManager.shared.getNewsFeed { result in
            DispatchQueue.main.async {
                self.setUpData(from: result)
            }
        }
    }
    
    private func setUpNotConnectedTableView() {
        resetTableView()
        newsFeedTableView.setEmptyView(message: "Connect your device to the internet!")
        refreshControl.endRefreshing()
    }
    
    private func setUpTableView(isFresh: Bool) {
        if isFresh {
            resetTableView()
            newsApi.refreshPage(1)
        }
        newsFeedTableView.setEmptyView(message: "Searching. Please wait.")
        settingsView.refreshSources()
    }
    
    private func resetTableView() {
        if !refreshControl.isRefreshing {
            newsFeed = []
            newsFeedTableView.reloadData()
        }
    }
    
    private func setUpData(from result: Articles) {
        if let numberOfNewsItems = result.totalResults {
            getNumberOfPages(numberOfNewsItems)
            errorTypeForArticles(numberOfNewsItems)
        }
        if refreshControl.isRefreshing {
            newsFeed = []
        }
        newsFeed.append(contentsOf: result.articles)
        newsFeedTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    private func getNumberOfPages(_ numberOfArticles: Int) {
        var numberOfPages = Int(numberOfArticles/20)
        if numberOfArticles%20 > 0 {
            numberOfPages += 1
        }
        newsPagesNumber = numberOfPages
    }
    
    private func errorTypeForArticles(_ numberOfArticles: Int) {
        if numberOfArticles != 0 {
            newsFeedTableView.restore()
        } else {
            newsFeedTableView.setEmptyView(message: "No results")
        }
    }
    
}

//MARK: - TableViewDelegate

extension NewsFeedViewController: TableViewTextDelegate {
    
    func errorType(_ text: String) {
        newsFeedTableView.setEmptyView(message: text)
        refreshControl.endRefreshing()
    }

}

//MARK: - SearchbarDelegate

extension NewsFeedViewController: SearchBarDelegate {
    
    func hideSearchBar() {
        keyWordSearchBar.text = ""
        hideKeyboardOnSearchBar()
    }
    
}
