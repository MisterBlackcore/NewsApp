import UIKit
import WebKit

class NewsViewController: UIViewController {

    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var addToFavoritesButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var newsWebView: FullScreenWKWebView!
    @IBOutlet private weak var newsSourceNameLabel: UILabel!
    
    var newsItem:NewsItemModel?
    var tableViewDelegate:TableViewDelegate?
    var newsSourceName:String?
    
    //MARK: - Main functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadURL()
        createCopyOfNewsItem()
    }
    
    //MARK: - IBActions
    
    @IBAction private func backButtonIsPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func addToFavoritesButtonIsPressed(_ sender: UIButton) {
        if let newsItem = newsItem {
            FavoritesManager.shared.favoritesAction(for: newsItem)
            changeButtonImage()
        }
        if let tableViewDelegate = tableViewDelegate {
            tableViewDelegate.refreshTableView()
        }
    }
    
    @IBAction private func shareButtonIsPressed(_ sender: UIButton) {
        shareURL()
    }
    
    //MARK: - Flow functions
    
    private func configUI() {
        configNewsSourceNameLabel()
        changeButtonImage()
    }
    
    private func configNewsSourceNameLabel() {
        newsSourceNameLabel.adjustsFontSizeToFitWidth = true
        if let newsSourceName = newsSourceName {
            newsSourceNameLabel.text = newsSourceName
        }
    }
    
    private func loadURL() {
        guard let newsItem = newsItem,
              let urlString = newsItem.url,
              let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let parsedUrl = URL(string: encodedString) else {
            return
        }
        let request = URLRequest(url: parsedUrl)
        newsWebView.load(request)
        newsWebView.allowsBackForwardNavigationGestures = true
    }
    
    private func shareURL() {
        guard let newsItem = newsItem, let urlString = newsItem.url, let url = URL(string: urlString) else {
            return
        }
        let itemsToShare = [url]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    private func changeButtonImage()  {
        guard let newsItem = newsItem else {
            return
        }
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light, scale: .large)
        var buttonImage = UIImage()
        if FavoritesManager.shared.inFavorites(newsItem) {
            buttonImage = UIImage(systemName: "star.fill", withConfiguration: configuration)!.withTintColor(.black, renderingMode: .alwaysOriginal)
        } else {
            buttonImage = UIImage(systemName: "star", withConfiguration: configuration)!.withTintColor(.black, renderingMode: .alwaysOriginal)
        }
        addToFavoritesButton.setImage(buttonImage, for: .normal)
    }
    
    func createCopyOfNewsItem() {
        guard let newsItem = newsItem else {
            return
        }
        let itemCopy = newsItem.copy()
        self.newsItem = itemCopy as? NewsItemModel
    }
    
}
