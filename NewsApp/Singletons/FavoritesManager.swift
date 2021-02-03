import UIKit
import RealmSwift

class FavoritesManager {
    
    var userPassword = ""
    var touchIDisActive = false
    var favorites = [NewsItemModel]()
    private let realm = try! Realm()

    static let shared = FavoritesManager()
    init () {}
    
    //MARK: - Flow functions
    
    func loadData() {
        loadFavorites()
        loadPassword()
        loadTouchIDSettings()
    }
    
    func savePassword(_ password: String) {
        UserDefaults.standard.set(password, forKey: "favoritesPassword")
        userPassword = password
    }
    
    private func loadPassword() {
        guard let password = UserDefaults.standard.string(forKey: "favoritesPassword") else {
            userPassword = ""
            return
        }
        userPassword = password
    }
    
    func saveTouchIDSettings(_ isActive: Bool) {
        UserDefaults.standard.set(isActive, forKey: "touchId")
        touchIDisActive = isActive
    }
    
    private func loadTouchIDSettings() {
        if UserDefaults.standard.bool(forKey: "touchId") {
            touchIDisActive = true
        } else {
            touchIDisActive = false
        }
    }
    
    private func loadFavorites() {
        favorites = Array(realm.objects(NewsItemModel.self))
    }
    
    func updateObject(_ model: NewsItemModel, with text: String) {
        try! realm.write {
            model.note = text
        }
    }
    
    func favoritesAction(for item: NewsItemModel) {
        if FavoritesManager.shared.inFavorites(item) {
            FavoritesManager.shared.removeFromFavorites(item)
        } else {
            FavoritesManager.shared.addToFavorites(item)
        }
    }
    
    private func addToFavorites(_ item: NewsItemModel) {
        let copy = item.copy() as! NewsItemModel
        favorites.append(copy)
        try! realm.write {
            realm.add(copy)
        }
    }
    
    private func removeFromFavorites(_ item: NewsItemModel) {
        var index = 0
        let itemCopy = item.copy() as! NewsItemModel
        for element in favorites {
            if itemCopy.equalTo(compareWith: element) {
                favorites.remove(at: index)
                try! realm.write {
                    realm.delete(element)
                }
                return
            }
            index += 1
        }
    }
    
    func inFavorites(_ item: NewsItemModel) -> Bool {
        for element in favorites {
            if item.equalTo(compareWith: element) {
                return true
            }
        }
        return false
    }
  
}
