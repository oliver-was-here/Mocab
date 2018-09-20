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
        print("background")
        
        configureWordNotifications()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("terminated")
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

