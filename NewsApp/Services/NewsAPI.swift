import UIKit

class NewsAPI {
    
    let body = "https://newsapi.org/v2/"
    let topHeadlinesEndpoint = "top-headlines?"
    let everythingEndpoint = "everything?"
    let sourcesEndpoint = "sources?"
    let apiKey = "81d624c8e60145229dae37551cc9dba2"
//    let apiKey = "3915276218364ea1ac85012e9808c08f"
//    let apiKey = "e5bedd4fae5d4f9ebc6a77dfdfdbae1a"
    //81d624c8e60145229dae37551cc9dba2 - first api key
    //3915276218364ea1ac85012e9808c08f - another api key
    //e5bedd4fae5d4f9ebc6a77dfdfdbae1a - third api key
    
    var currentEndpoint = "top-headlines?"
    var currentParameters = [URLQueryItem]()
    
    var page:Int = 1
    var currentUserCountry:String?
    var countryCode:String?
    var category:String?
    var source:String?
    var searchWord:String?
    
    //MARK: - Flow functions
    
    func addApiParameters() {
        var parameters = [URLQueryItem]()
        if let searchWord = searchWord, searchWord != "" {
            let item = URLQueryItem(name: "q", value: searchWord)
            parameters.append(item)
        }
        if let source = source {
            let item = URLQueryItem(name: "sources", value: source)
            parameters.append(item)
            currentParameters = parameters
            return
        }
        if let code = countryCode {
            let item = URLQueryItem(name: "country", value: code)
            parameters.append(item)
        }
        if let category = category {
            let item = URLQueryItem(name: "category", value: category)
            parameters.append(item)
        }
        currentParameters = parameters
    }
    
    func refreshPage(_ number: Int) {
        checkIfcontainsPage()
        page = number
        let item = URLQueryItem(name: "page", value: "\(page)")
        currentParameters.append(item)
    }
    
    private func checkIfcontainsPage() {
        var index = 0
        var containtsPage = false
        for parameter in currentParameters {
            if parameter.name == "page" {
                containtsPage = true
                break
            }
            index += 1
        }
        if containtsPage {
            currentParameters.remove(at: index)
        }
    }
    
    func refreshParameters(sources: Bool) {
        if sources {
            countryCode = nil
            category = nil
        } else {
            source = nil
        }
    }
    
    func refreshAllParameters() {
        countryCode = nil
        category = nil
        source = nil
    }
    
}
