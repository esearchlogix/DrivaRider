//
//  UserDetail.swift
//  holidayshare
//
//  Created by Preeti Dhankar on 01/04/18.
//  Copyright © 2018 Preeti Dhankar. All rights reserved.
//

import UIKit

class UserDetail: NSObject {
static let shared = UserDetail()
    private override init() { }
    
//    func setUserId(_ sUserId:String) -> Void {
//        UserDefaults.standard.set(sUserId, forKey: UserKeys.user_id.rawValue)
//    }
//    func getUserId() -> String {
//        if let userId = UserDefaults.standard.value(forKey: UserKeys.user_id.rawValue) as? String {
//            return userId
//        }
//        return ""
//    }
    
    func setUserInfo(_ userInfo:AnyObject) -> Void {
        UserDefaults.standard.set(userInfo, forKey: UserKeys.user_info.rawValue)
    }
    
    func getUserInfo() -> AnyObject {
        let user_info = UserDefaults.standard.value(forKey: UserKeys.user_info.rawValue) as AnyObject
        return user_info
    }
    
    func setUserImage(_ userInfo:String) -> Void {
        UserDefaults.standard.set(userInfo, forKey: UserKeys.user_img.rawValue)
    }
    
    func getUserImage() -> String {
        let user_image = UserDefaults.standard.value(forKey: UserKeys.user_img.rawValue) as! String
        return user_image
    }

    func setUserLogin(_ isLogin:Bool) -> Void {
        UserDefaults.standard.set(isLogin, forKey: UserKeys.isLogin.rawValue)
    }
    
    func isUserLogin() -> Bool {
        let isLogin = UserDefaults.standard.bool(forKey: UserKeys.isLogin.rawValue)
        return isLogin
    }

    func setUserToken_id(_ sUserId:String) -> Void {
        UserDefaults.standard.set(sUserId, forKey: UserKeys.isToken.rawValue)
    }
    func getToken_Id() -> String {
        if let tokenId = UserDefaults.standard.value(forKey: UserKeys.isToken.rawValue) as? String {
            return tokenId
        }
        return ""
    }

}

enum UserKeys:String {
    
    case user_info = "user_info"
    
    case user_email = "user_email"
    case user_fullname = "user_fullname"
    case user_id = "user_id"
    case user_img = "user_img"
    case user_mob = "user_mob"
    case user_type = "user_type"
    case wallet_balance = "wallet_balance"
    case wallet_id = "wallet_id"
    case about = "about"
    case isLogin = "isLogin"
    case isToken = "TokenId"
}
