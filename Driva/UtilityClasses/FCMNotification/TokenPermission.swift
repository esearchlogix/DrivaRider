//
//  TokenPermission.swift
//  Work2go
//
//  Created by Rajesh Gupta on 6/23/18.
//  Copyright © 2018 Rajesh Gupta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func requestNotificationAuthorization(application: UIApplication) {
        
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert,.badge,.sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (success, error) in
                Messaging.messaging().delegate = self
            })
        }else{
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[kGCMMessageIDKey] {
//            print("Message ID: \(messageID)")
        }
        
        // Print full message.
//        print(userInfo)
        
        if (userInfo["gcm.notification.type"] as! String == "ride_accepted") {
            NotificationCenter.default.post(name: Notification.Name("acceptNotification"), object: nil, userInfo: userInfo)
        } else if (userInfo["gcm.notification.type"] as! String == "ride_canceled"){
            NotificationCenter.default.post(name: Notification.Name("cancelNotification"), object: nil, userInfo: userInfo)
        }else if (userInfo["gcm.notification.type"] as! String == "ride_finish"){
            NotificationCenter.default.post(name: Notification.Name("finishNotification"), object: nil, userInfo: userInfo)
        }else if (userInfo["gcm.notification.type"] as! String == "ride_start"){
            NotificationCenter.default.post(name: Notification.Name("startNotification"), object: nil, userInfo: userInfo)
        }else if (userInfo["gcm.notification.type"] as! String == "delete"){
            _ = UserDetail.shared.setUserLogin(false)
            let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate
            APPDELEGATE.loadLoginView()
        }
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[kGCMMessageIDKey] {
//            print("Message ID: \(messageID)")
        }
        if (userInfo["gcm.notification.type"] as! String == "delete"){
            _ = UserDetail.shared.setUserLogin(false)
            let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate
            APPDELEGATE.loadLoginView()
        }
        // Print full message.
//        print(userInfo)
        
//        if (userInfo["gcm.notification.type"] as! String == "ride_accepted") {
//            NotificationCenter.default.post(name: Notification.Name("acceptNotification"), object: nil, userInfo: userInfo)
//        } else if (userInfo["gcm.notification.type"] as! String == "ride_canceled"){
//            NotificationCenter.default.post(name: Notification.Name("cancelNotification"), object: nil, userInfo: userInfo)
//        }else if (userInfo["gcm.notification.type"] as! String == "ride_finish"){
//            NotificationCenter.default.post(name: Notification.Name("finishNotification"), object: nil, userInfo: userInfo)
//        }else if (userInfo["gcm.notification.type"] as! String == "ride_start"){
//            NotificationCenter.default.post(name: Notification.Name("startNotification"), object: nil, userInfo: userInfo)
//        }

        completionHandler()
    }
    
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
//        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.setToken(value: fcmToken)
        
//        DispatchQueue.main.async {
//            RegisterFCM().registerFcnTokenOnServer(with: fcmToken)
//        }
//
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
//                print("Remote instance ID token: \(result.token)")
//                self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
            }
        }
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        UIApplication.shared.applicationIconBadgeNumber = 0
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[kGCMMessageIDKey] {
//            print("Message ID: \(messageID)")
        }
        if UIApplication.shared.applicationState == .active {
            
            FCMNotification().didReciveNotification(with: userInfo as! [String : Any])
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            //TODO: Handle foreground notification
        } 
//        print(userInfo)
        completionHandler(.newData)
    }
    
}
