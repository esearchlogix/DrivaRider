//
//  FCMRegistration.swift
//  Work2go
//
//  Created by Rajesh Gupta on 6/23/18.
//  Copyright © 2018 Rajesh Gupta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging


class RegisterFCM {
    
    func registerFcnTokenOnServer(with fcmToken:String){
        
        if UserDefaults.standard.isLoggedIn() {
            deviceRegisterOnServer(with: fcmToken)
        }
    }

    private func deviceRegisterOnServer(with fcmToken:String){
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let Item = ["user_id": userId,"token_id": "\(UserDefaults.standard.getToken() ?? "")","device_id": "\(UserDefaults.standard.getDeviceID())","device_type": "ios"]
        let url = kServer + KServerPath + K_PushDeviceRegistrationApi
        
        APIHelper.shared.callAPIPost(Item, sUrl: url, completion: { (response) in
            if let JSON = response{
                if let status = ((JSON as? NSDictionary)! as AnyObject).value(forKey: "status") as? String {
                    if status == "1" {
                        let message = ((JSON as? NSDictionary)! as AnyObject).value(forKey: "message") as? String
//                        print("Divece Registered : ",message!)
                    }else{
                        let message = ((JSON as? NSDictionary)! as AnyObject).value(forKey: "message") as? String
//                        print(message!)
                    }
                }
            }else{
            }
        })

    }
    
    func saveFcmTokenOnLogin()  {
        if let fcm = UserDefaults.standard.getToken() {
            self.deviceRegisterOnServer(with: fcm)
        }else{
            if let token = Messaging.messaging().fcmToken {
                UserDefaults.standard.setToken(value: token)
                self.deviceRegisterOnServer(with: token)
            }
        }
    }
}
