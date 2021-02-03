import UIKit

private let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    
    private var task:URLSessionDataTask!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    //MARK: - Flow functions
    
    func loadImage(from url: URL) {
        image = nil
        addActivityIndicator()
        if let task = task {
            task.cancel()
        }
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            image = imageFromCache
            removeActivityIndicator()
            return
        }
        let session = URLSession.shared
        let request = URLRequest(url: url)
        task = session.dataTask(with: request) { data, response, error in
            guard let data = data, let newImage = UIImage(data: data) else {
                return
            }
            imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
            DispatchQueue.main.async {
                self.image = newImage
                self.removeActivityIndicator()
            }
        }
        task.resume()
    }
    
    private func addActivityIndicator() {
        addSubview(activityIndicator)
        setUpActivityIndicatorConstraints()
        activityIndicator.startAnimating()
    }
    
    private func setUpActivityIndicatorConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    private func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
    }
    
}
