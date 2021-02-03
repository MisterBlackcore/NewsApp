import UIKit
import RealmSwift

class SourceModel:Object, Codable {
    @objc dynamic var id:String?
    @objc dynamic var name:String?
}
