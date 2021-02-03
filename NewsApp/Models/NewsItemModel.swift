import UIKit
import RealmSwift

class NewsItemModel: Object, Codable, NSCopying {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var source:SourceModel?
    @objc dynamic var title:String?
    @objc dynamic var desc:String?
    @objc dynamic var url:String?
    @objc dynamic var urlToImage:String?
    @objc dynamic var publishedAt:String?
    @objc dynamic var note:String?
    
    override static func primaryKey() -> String? {
            return "id"
    }
    
    private enum CodingKeys:String, CodingKey {
        case source, title, url, urlToImage, publishedAt, note, desc = "description"
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = NewsItemModel()
        copy.id = id
        copy.source = source
        copy.title = title
        copy.desc = desc
        copy.url = url
        copy.urlToImage = urlToImage
        copy.publishedAt = publishedAt
        copy.note = note
        return copy
    }
    
    func equalTo(compareWith item: NewsItemModel) -> Bool {
        return
            self.title == item.title &&
            self.desc == item.desc &&
            self.url == item.url &&
            self.urlToImage == item.urlToImage &&
            self.publishedAt == item.publishedAt
    }

}
