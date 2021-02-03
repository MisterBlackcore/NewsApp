import UIKit

class NetworkManager {
    
    var newsApi = NewsAPI()
    var tableViewDelegate:TableViewTextDelegate?
    private var dataTask:URLSessionDataTask!
    
    static let shared = NetworkManager()
    init () {}
    
    //MARK: - Flow functions
    
    func getNewsFeed(completion: @escaping (Articles) -> Void) {
        if let task = dataTask {
            task.cancel()
        }
        guard var urlComponents = URLComponents(string:"\(newsApi.body)\(newsApi.currentEndpoint)") else {
            return
        }
        urlComponents.queryItems = newsApi.currentParameters
        guard let url = urlComponents.url else {
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue(newsApi.apiKey, forHTTPHeaderField: "X-Api-Key")
        dataTask = session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let articles = try JSONDecoder().decode(Articles.self, from: data)
                    completion(articles)
                } catch {
                    print("error: \(error)")
                    DispatchQueue.main.async {
                        self.errorType()
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func getNewsSources(completion: @escaping (Sources) -> Void) {
        guard let url = URL(string:"\(newsApi.body)\(newsApi.sourcesEndpoint)") else {
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue(newsApi.apiKey, forHTTPHeaderField: "X-Api-Key")
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let sources = try JSONDecoder().decode(Sources.self, from: data)
                    completion(sources)
                } catch {
                    print("error: \(error)")
                }
            }
        }.resume()
    }
    
    private func errorType() {
        var failMessage = ""
        if newsApi.currentEndpoint == newsApi.everythingEndpoint {
            failMessage = "Choose the source or enter the keyword"
        }
        if newsApi.currentEndpoint == newsApi.topHeadlinesEndpoint {
            failMessage = "Enter the keyword or choose a country, category or source."
        }
        guard let delegate = tableViewDelegate else {
            return
        }
        delegate.errorType(failMessage)
    }
    
}
