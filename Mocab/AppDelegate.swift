import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static private let CURRENT_WORD_KEY = "wordInProgress"
    private var center: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    private let termsService = ServiceInjector.termsService

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        configureWordNotifications()
    }
}

extension AppDelegate {
    // MARK: Private
    private func configureWordNotifications() {
        clearOldNotifications()
        
        createNewNotifications()
    }
    
    private func clearOldNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [AppDelegate.CURRENT_WORD_KEY])
    }
    
    private func createNewNotifications() {
        if let inProgressTerm = termsService.getInProgressTerm() {
            let notification = UNMutableNotificationContent()
            notification.title = inProgressTerm.term
            notification.body = inProgressTerm.definition
            
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 61, repeats: true)
            let request = UNNotificationRequest(
                identifier: AppDelegate.CURRENT_WORD_KEY,
                content: notification,
                trigger: notificationTrigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("ERROR: \(String(describing: error))")
                }
            }
        }
    }
}
