import UIKit

class TableViewService {

    private let categories = ["Business", "Entertainment", "General", "Health", "Science", "Sports", "Technology"]
    private var countryCodes = [CountryModel(name: "Argentina", code: "ar"),
                                CountryModel(name: "Austria", code: "at"),
                                CountryModel(name: "Australia", code: "au"),
                                CountryModel(name: "Belgium", code: "be"),
                                CountryModel(name: "Brazil", code: "br"),
                                CountryModel(name: "Bulgaria", code: "bg"),
                                CountryModel(name: "Canada", code: "ca"),
                                CountryModel(name: "China", code: "cn"),
                                CountryModel(name: "Columbia", code: "co"),
                                CountryModel(name: "Cuba", code: "cu"),
                                CountryModel(name: "Czech Republic", code: "cz"),
                                CountryModel(name: "Egypt", code: "eg"),
                                CountryModel(name: "France", code: "fr"),
                                CountryModel(name: "Germany", code: "de"),
                                CountryModel(name: "Greece", code: "gr"),
                                CountryModel(name: "Hong Kong", code: "hk"),
                                CountryModel(name: "Hungary", code: "hu"),
                                CountryModel(name: "India", code: "in"),
                                CountryModel(name: "Indonesia", code: "id"),
                                CountryModel(name: "Ireland", code: "ie"),
                                CountryModel(name: "Israel", code: "il"),
                                CountryModel(name: "Italy", code: "it"),
                                CountryModel(name: "Japan", code: "jp"),
                                CountryModel(name: "Lithuania", code: "lt"),
                                CountryModel(name: "Latvia", code: "lv"),
                                CountryModel(name: "Malaysia", code: "my"),
                                CountryModel(name: "Mexico", code: "mx"),
                                CountryModel(name: "Morocco", code: "ma"),
                                CountryModel(name: "New Zeland", code: "nz"),
                                CountryModel(name: "Nigeria", code: "ng"),
                                CountryModel(name: "Norway", code: "no"),
                                CountryModel(name: "Philippines", code: "ph"),
                                CountryModel(name: "Poland", code: "pl"),
                                CountryModel(name: "Portugal", code: "pt"),
                                CountryModel(name: "Romania", code: "ro"),
                                CountryModel(name: "Russia", code: "ru"),
                                CountryModel(name: "Serbia", code: "rs"),
                                CountryModel(name: "Singapore", code: "sg"),
                                CountryModel(name: "Slovakia", code: "sk"),
                                CountryModel(name: "Slovenia", code: "si"),
                                CountryModel(name: "South Arabia", code: "sa"),
                                CountryModel(name: "South Korea", code: "kr"),
                                CountryModel(name: "Sweden", code: "se"),
                                CountryModel(name: "Switzerland", code: "ch"),
                                CountryModel(name: "Taiwan", code: "tw"),
                                CountryModel(name: "Thailand", code: "th"),
                                CountryModel(name: "The Netherlands", code: "nl"),
                                CountryModel(name: "Turkey", code: "tr"),
                                CountryModel(name: "Ukraine", code: "ua"),
                                CountryModel(name: "United Arab Emirates", code: "ae"),
                                CountryModel(name: "United Kingdom", code: "gb"),
                                CountryModel(name: "United States", code: "us"),
                                CountryModel(name: "South Africa", code: "za"),
                                CountryModel(name: "Venezuela", code: "ve")]
    private var sources = [SourceModel]()
    
    var currentOption:SettingsOption?
    var chosenOptionButton:UIButton?
    var chosenOptionRefreshButton:UIButton?
    var xibAnimationDelegate:XIBAnimtionDelegate?
    
    init() {
        getNewsSourcesArray()
    }
    
    //MARK: - Flow functions
    
    private func getNewsSourcesArray() {
        NetworkManager.shared.getNewsSources { (sources) in
            DispatchQueue.main.async {
                if let sources = sources.sources {
                    self.sources = sources
                }
            }
        }
    }
    
    func loadSources() {
        if sources.count == 0 {
            getNewsSourcesArray()
        }
    }
    
    func addUserCountry(_ country: CountryModel) {
        countryCodes.insert(country, at: 0)
    }
    
    func numberOfComponents() -> Int {
        guard let option = currentOption else {
            return 0
        }
        switch option {
        case .categories:
            return categories.count
        case .countries:
            return countryCodes.count
        case .sources:
            return sources.count
        }
    }
    
    func titleForRow(_ row: Int) -> String {
        guard let option = currentOption else {
            return "Failed"
        }
        switch option {
        case .categories:
            return categories[row]
        case .countries:
            return countryCodes[row].name
        case .sources:
            guard let sourceName = sources[row].name else {
                return "Failed"
            }
            return sourceName
        }
    }
    
    func addParameter(row: Int,in newsApi: NewsAPI) {
        guard let option = currentOption,
              let button = chosenOptionButton,
              let refreshButton = chosenOptionRefreshButton,
              let delegate = xibAnimationDelegate else {
            return
        }
        switch option {
        case .categories:
            newsApi.category = categories[row]
            newsApi.refreshParameters(sources: false)
            button.setTitle(categories[row], for: .normal)
            delegate.animateSourceView(isHidden: false)
        case .countries:
            newsApi.countryCode = countryCodes[row].code
            newsApi.refreshParameters(sources: false)
            button.setTitle(countryCodes[row].name, for: .normal)
            delegate.animateSourceView(isHidden: false)
        case .sources:
            newsApi.source = sources[row].id
            newsApi.refreshParameters(sources: true)
            button.setTitle(sources[row].name, for: .normal)
            delegate.animateCountriesAndCategoriesView(isHidden: false)
        }
        showRefreshButton(refreshButton)
    }
    
    private func showRefreshButton(_ button: UIButton) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light, scale: .medium)
        let buttonImage = UIImage(systemName: "xmark", withConfiguration: configuration)!.withTintColor(.red, renderingMode: .alwaysOriginal)
        button.setImage(buttonImage, for: .normal)
        button.isHidden = false
    }
    
}
