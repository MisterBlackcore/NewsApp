import UIKit

extension UITableView {
    
    func setEmptyView(message: String) {
        let emptyBackgroundView = UIView()
        emptyBackgroundView.frame = CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height)
        let messageLabel = UILabel()
        setUpLabel(messageLabel, with: message)
        emptyBackgroundView.addSubview(messageLabel)
        setUpLabelConstraints(messageLabel, equalTo: emptyBackgroundView)
        self.backgroundView = emptyBackgroundView
        self.separatorStyle = .none
    }
    
    private func setUpLabel(_ label: UILabel, with message: String) {
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        label.text = message
    }
    
    private func setUpLabelConstraints(_ label: UILabel, equalTo view: UIView) {
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
}
