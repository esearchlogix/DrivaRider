//
//  LoginViewController.swift
//  Driva
//
//  Created by mediatrenz on 23/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import Alamofire
import ASProgressHud

class LoginViewController: UIViewController {

    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailIdTxt: UITextField!
    @IBOutlet weak var emailViewBg: UIView!
    @IBOutlet weak var passwordViewbg: UIView!
    var rsaKeyDataStr = String()
    var rsaKeyUrl = "http://tabletshablet.co.in/api/GetRSA.php?"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let isLogin = UserDetail.shared.isUserLogin()
        if isLogin {
            let userObj = UserDetail.shared.getUserInfo()
            let userImage = userObj.value(forKey: UserKeys.user_img.rawValue) as! String
            _ = UserDetail.shared.setUserImage(userImage)
            _ = UserDetail.shared.setUserLogin(true)
            self.gotoHomePage()
        }else{
//            defaults.set(true, forKey: "ISRemember")
            ViewDidLordItemCall()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
      //  self.emailIdTxt.becomeFirstResponder()
//        if defaults.bool(forKey: "ISRemember") {
//            if (defaults.value(forKey: "SavedEmailID") != nil) {
//                emailIdTxt.text = (defaults.value(forKey: "SavedEmailID") as! String)
//                passwordTxt.text = (defaults.value(forKey: "SavedPassword") as! String)
//                }
//                else {
//                emailIdTxt.text = ""
//                passwordTxt.text = ""
//            }
//        }else {
//            emailIdTxt.text = ""
//            passwordTxt.text = ""
//        }
        emailIdTxt.text = ""
        passwordTxt.text = ""

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        
//        gotoHomePage()
        
    if (emailIdTxt.text == nil ||  emailIdTxt.text == ""){
        PDAlert.shared.showAlertWith("Oops!", message: "Please enter a email address", onVC: self)
        return
    }
    
    if !(emailIdTxt.text?.isValidEmail)!{
        PDAlert.shared.showAlertWith("Oops!", message: "Please enter a valid email address", onVC: self)
        return
    }
    
    if (passwordTxt.text == nil ||  passwordTxt.text == ""){
        PDAlert.shared.showAlertWith("Oops!", message: "Please enter Password", onVC: self)
        return
    }
    
    
        if Connectivity.isConnectedToInternet {
            API_Calling_For_Login()
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }
    }
    
    @IBAction func signupBtnAction(_ sender: UIButton) {
        
        let storyBord : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBord.instantiateViewController(withIdentifier: "signUpViewController") as! signUpViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

fileprivate func gotoHomePage()
    {
        APPDELEGATE.loadMenu()
    }

    @IBAction func forgetPasswordAction(_ sender: UIButton) {
        
        let storyBord : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBord.instantiateViewController(withIdentifier: "forgetPwdViewController") as! forgetPwdViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    @IBAction func rememberMeButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            defaults.set(true, forKey: "ISRemember")
            defaults.set(emailIdTxt.text, forKey: "SavedEmailID")
            defaults.set(passwordTxt.text, forKey: "SavedPassword")
        }
        else {
            defaults.set(false, forKey: "ISRemember")
            defaults.set("", forKey: "SavedEmailID")
            defaults.set("", forKey: "SavedPassword")
        }

    }
    
    func savedData() {
//        if defaults.bool(forKey: "ISRemember") {
//            defaults.set(emailIdTxt.text, forKey: "SavedEmailID")
//            defaults.set(passwordTxt.text, forKey: "SavedPassword")
//            defaults.set(false, forKey: "ISRemember")
//
//        }
//        else {
//            defaults.set(false, forKey: "ISRemember")
//            defaults.set("", forKey: "SavedEmailID")
//            defaults.set("", forKey: "SavedPassword")
//        }
        
        defaults.set("", forKey: "SavedEmailID")
        defaults.set("", forKey: "SavedPassword")

    }
    
    //MARK: Login API ////////////////////////////////////////////////////////////////////////////
    func API_Calling_For_Login() -> Void {
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        let Item = ["email":emailIdTxt.text!,"password": passwordTxt.text!]
        let url = NearLoginUrlStruct().URL_LOGIN
        APIHelper.shared.callAPIPost(Item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.loginSucceesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                PDAlert.shared.showAlertWith("Alert!", message: "Unable to login.", onVC: self)
            }
        })
    }
    
    func API_Calling_For_RegisterDevice() -> Void {
        
        let deviceId = defaults.getDeviceID()
        let deviceToken = defaults.getToken()
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String

        let Item = ["user_id": userId,"token_id": deviceToken,"device_id": deviceId,"device_type": "ios"]
        
        let url = kServer + KServerPath + K_PushDeviceRegistrationApi
        
        APIHelper.shared.callAPIPost(Item, sUrl: url, completion: { (response) in
            if let JSON = response{
                self.succeesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
            }
        })
                
    }

    func loginSucceesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let userInfo = Parser.shared.getAnyObjectFrom(data: (result as AnyObject), key: "user_info")
                _ = UserDetail.shared.setUserInfo(userInfo)
                
                let userObj = UserDetail.shared.getUserInfo()
                let userImage = userObj.value(forKey: UserKeys.user_img.rawValue) as! String
                _ = UserDetail.shared.setUserImage(userImage)
                _ = UserDetail.shared.setUserLogin(true)
                
                self.savedData()
                gotoHomePage()
                
                DispatchQueue.main.async {
                    RegisterFCM().saveFcmTokenOnLogin()
                }

            }else if status == "2" {
                
                
                self.savedData()
                
                let otpVerificationVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                otpVerificationVC.user_id = (result as AnyObject).value(forKey: "user_id") as? String ?? ""
                otpVerificationVC.mobileNumber = Parser.shared.getAnyObjectFrom(data: (result as AnyObject), key: "user_mob") as? String
                self.navigationController?.pushViewController(otpVerificationVC, animated: true)
                
                //gotoHomePage()
                
//                DispatchQueue.main.async {
//                    RegisterFCM().saveFcmTokenOnLogin()
//                }
                
            }
            
            else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                PDAlert.shared.showAlertWith("Alert!", message: message, onVC: self)
            }
        }
    }
    
    func succeesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let message = (result as AnyObject).value(forKey: "message") as? String
//                print("Divece Registered : ",message!)
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
//                print(message!)
            }
        }
    }

}

extension LoginViewController {
    func ViewDidLordItemCall() -> Void {
        
        self.loginBtn.layer.cornerRadius = 8
        self.signupBtn.layer.cornerRadius = 8
        
        emailIdTxt.setLeftPaddingPoints(10)
        emailViewBg.addViewBottomBorderWithColor(color: UIColor.black, width: 1)
        
        passwordTxt.setLeftPaddingPoints(10)
        passwordViewbg.addViewBottomBorderWithColor(color: UIColor.black, width: 1)
     
    }
    
}
