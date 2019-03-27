//
//  FCMNotification.swift
//  Work2go
//
//  Created by Rajesh Gupta on 6/23/18.
//  Copyright © 2018 Rajesh Gupta. All rights reserved.
//

import UIKit
import RNNotificationView
import AudioToolbox

class FCMNotification {
    
    func didReciveNotification(with userInfo:[String:Any]) {
        
        AudioServicesPlaySystemSound(1315);
        RNNotificationView.show(withImage: UIImage(named: "applogo"),
                                title: self.extractTitle(fromPushNotificationUserInfo: userInfo),
                                message: self.extractMessage(fromPushNotificationUserInfo: userInfo),
                                duration: 5,
                                iconSize: CGSize(width: 40, height: 40), // Optional setup
            onTap: {
//                print("Did tap notification")
                self.didTapOnNotifications(with: userInfo)
        }
        )
    }
    
    private func extractMessage(fromPushNotificationUserInfo userInfo:[String:Any]) -> String? {
     
        var message: String?
        if let aps = userInfo["aps"] as? [String:Any] {
            if let alert = aps["alert"] as? [String:Any] {
                if let alertMessage = alert["body"] as? String {
                    message = alertMessage
                }
            }
        }
        return message
    }
    private func extractTitle(fromPushNotificationUserInfo userInfo:[String:Any]) -> String? {
        var notificationTitle: String?
        if let aps = userInfo["aps"] as? [String:Any] {
            if let alert = aps["alert"] as? [String:Any] {
                if let alertMessage = alert["title"] as? String {
                    notificationTitle = alertMessage
                }
            }
        }
        return notificationTitle
    }
    
     func didTapOnNotifications(with userInfo:[String:Any])  {
        
        let info = userInfo["aps"] as! [String:Any]
        let job_ts = info["alert"] as! [String:Any]
        let job_t = job_ts["title"] as! String
        
        UserDefaults.standard.set(userInfo["gcm.notification.job_id"], forKey: "job_id")
        UserDefaults.standard.set(userInfo["gcm.notification.sender_id"], forKey: "receiver_id")
        UserDefaults.standard.set(userInfo["gcm.notification.reciver_name"], forKey: "receiver_name")
        UserDefaults.standard.set(job_t, forKey: "job_title")
        UserDefaults.standard.set(true, forKey: "isBackgroundState")
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let nav = UINavigationController(rootViewController: loginViewController)
        appdelegate.window?.rootViewController = nav
        appdelegate.window?.makeKeyAndVisible()
    }
    
}
