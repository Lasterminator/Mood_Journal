import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .appWillResignActive, object: nil)
    }
}

extension Notification.Name {
    static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
    static let appWillResignActive = Notification.Name("appWillResignActive")
}
