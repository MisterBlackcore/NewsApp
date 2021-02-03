import UIKit
import Reachability

struct InternetConnectionService {
    
    static func connectedToInternet() -> Bool {
        var reachability:Reachability?
        reachability = try? Reachability.init()
        var isConnected = false
        if ((reachability!.connection) != .unavailable) {
            isConnected = true
        }
        return isConnected
    }
    
}
