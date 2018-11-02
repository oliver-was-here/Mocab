import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static private let CURRENT_TERM_KEY = "termInProgress"
    private var center: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    private let termsService = ServiceInjector.termsService

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            if let error = error {
                print("ERROR: requestAuthorization failed: \(error)")
            }
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        configureTermNotifications()
    }
}

extension AppDelegate {
    // MARK: Private
    private func configureTermNotifications() {
        clearOldNotifications()
        
        createNewNotifications()
    }
    
    private func clearOldNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [AppDelegate.CURRENT_TERM_KEY])
    }
    
    private func createNewNotifications() {
        if let inProgressTerm = termsService.getInProgressTerm() {
            let notification = UNMutableNotificationContent()
            notification.title = inProgressTerm.asEntered
            notification.body = inProgressTerm.definition
            
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 61, repeats: true)
            let request = UNNotificationRequest(
                identifier: AppDelegate.CURRENT_TERM_KEY,
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
