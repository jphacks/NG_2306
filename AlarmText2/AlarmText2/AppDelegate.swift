//
//  AppDelegate.swift
//  AlarmText2
//
//  Created by 小西貴洋 on 2023/10/28.
//

//
//  AppDelegate.swift
//  AlarmTest
//
//  Created by Takuto Hyuga on 2023/10/28.
//
 
import UIKit
import UserNotifications
 
@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
 
 
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    print("Error requesting notification authorization: \(error.localizedDescription)")
                }
            }
            
            // UNUserNotificationCenterのデリゲートを設定する
            UNUserNotificationCenter.current().delegate = self
        return true
    }
 
    // MARK: UISceneSession Lifecycle
 
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
 
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
 
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "alarm" {
            // アラームがトリガーされたときに画面遷移する
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "Talk")
            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
        }
        
        completionHandler()
    }
 
    
 
}
