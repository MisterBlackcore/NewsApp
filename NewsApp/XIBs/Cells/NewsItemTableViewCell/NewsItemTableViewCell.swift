import UIKit

class NewsItemTableViewCell: UITableViewCell {

    @IBOutlet private weak var newsItemImageView: CustomImageView!
    @IBOutlet private weak var newsItemTitleLabel: UILabel!
    @IBOutlet private weak var newsItemTimeLabel: UILabel!
    @IBOutlet private weak var newsItemDescriptionLabel: UILabel!
    
    func configCell(with model: NewsItemModel) {
        newsItemTitleLabel.text = model.title
        newsItemTimeLabel.text = convertDate(dateString: model.publishedAt!)
        newsItemDescriptionLabel.text = model.desc
        guard let imageUrl = model.urlToImage, let url = URL(string: imageUrl) else {
            newsItemImageView.image = UIImage(named: "noImage")
            return
        }
        newsItemImageView.loadImage(from: url)
    }
    
    private func convertDate(dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate,
                                      .withTime,
                                      .withDashSeparatorInDate,
                                      .withColonSeparatorInTime]
        guard let date = isoFormatter.date(from: dateString) else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm MMM dd, yyyy"
        return "Published at \(dateFormatter.string(from: date))"
    }
    
}
