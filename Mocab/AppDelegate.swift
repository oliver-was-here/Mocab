import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static private let TIME_TO_SNOOZE = Time(days: 10).toSeconds()
    static private let CURRENT_TERM_KEY = "termInProgress"
    private var center: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    private let termsService = ServiceInjector.termsService

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            if let error = error {
                log(.error, "requestAuthorization failed: \(error)")
            }
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        configureTermNotifications()
        
        let wakeUpDate = Date(timeIntervalSinceNow: -AppDelegate.TIME_TO_SNOOZE)
        awakenSnoozedTerm(ifOlderThan: wakeUpDate)
    }
}

extension AppDelegate {
    // MARK: Private
    private func awakenSnoozedTerm(ifOlderThan awakenDate: Date) {
        ServiceInjector.termsService
            .getAll(.snoozed, for: nil)
            .filter { $0.lastStatusUpdate.compare(awakenDate) == .orderedAscending }
            .map { $0.changeValues(status: .inProgress) }
            .forEach { ServiceInjector.termsService.save($0, for: nil) }
    }
    
    private func configureTermNotifications() {
        clearOldNotifications()
        
        createNewNotifications()
    }
    
    private func clearOldNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [AppDelegate.CURRENT_TERM_KEY])
    }
    
    private func createNewNotifications() {
        if let inProgressTerm = termsService.inProgressTerm {
            let notification = UNMutableNotificationContent()
            notification.title = inProgressTerm.asEntered
            notification.body = inProgressTerm.definition
            
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 5, repeats: true)
            let request = UNNotificationRequest(
                identifier: AppDelegate.CURRENT_TERM_KEY,
                content: notification,
                trigger: notificationTrigger
            )
            
            center.add(request) { error in
                if let error = error {
                    log(.error, "\(String(describing: error))")
                }
            }
        }
    }
}
