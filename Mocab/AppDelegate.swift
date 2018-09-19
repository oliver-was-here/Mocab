import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static private let CURRENT_WORD_KEY = "wordInProgress"
    private var center: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        if let encoded = try? SerializationMapper.encoder.encode([
                Term(term: "word1", definition: "def1"),
                Term(term: "word2", definition: "def2")]
            ) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: LearningTermsController.LEARNING_TERMS_KEY)
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
        if let learningWordsJson = UserDefaults
            .standard
            .object(forKey: LearningTermsController.LEARNING_TERMS_KEY) as? Data,
            let learningWords = try? SerializationMapper.decoder
                .decode([Term].self, from: learningWordsJson),
            let currentTerm = learningWords.first
        {
            let notification = UNMutableNotificationContent()
            notification.title = currentTerm.term
            notification.body = currentTerm.definition
            
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

