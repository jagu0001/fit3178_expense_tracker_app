//
//  AppDelegate.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 4/21/21.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var databaseController: DatabaseProtocol?
    let CATEGORY_IDENTIFIER = "edu.monash.fit3178.Expense-Tracker-App.category"
    var notificationsEnabled = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = CoreDataController()
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            if granted {
                self.notificationsEnabled = granted
                UNUserNotificationCenter.current().delegate = self
                
                
                let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept", options: .foreground)
                let declineAction = UNNotificationAction(identifier: "decline", title: "Decline", options: .destructive)
                let commentAction = UNTextInputNotificationAction(identifier: "comment", title: "Comment", options: .authenticationRequired, textInputButtonTitle: "Send", textInputPlaceholder: "Share your thoughts..")
                
                // Set up the category
                let appCategory = UNNotificationCategory(identifier: self.CATEGORY_IDENTIFIER, actions: [acceptAction, declineAction, commentAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
                
                // Register the category just created with the notification centre
                UNUserNotificationCenter.current().setNotificationCategories([appCategory])
            }
        }
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
    
    // MARK:- UNUserNotificationCenterDelegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification arrived")
        
        completionHandler(.banner)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.content.categoryIdentifier == CATEGORY_IDENTIFIER {
            switch response.actionIdentifier {
            
            case "accept":
                print("accept")
            case "decline":
                print("decline")
            case "comment":
                print("comment")
                if let response = response as? UNTextInputNotificationResponse {
                    print(response.userText)
                    UserDefaults.standard.set(response.userText, forKey: "response")
                }
            default:
                print("default")
            }
        }
        
        completionHandler()
    }
    
}

