//
//  OTPViewController.swift
//  DRIVA Partner
//
//  Created by Alekh Verma on 07/01/19.
//  Copyright © 2019 Manoj Singh. All rights reserved.
//

import UIKit
import ASProgressHud

class OTPViewController: UIViewController {
   @IBOutlet var textFieldOTP : UITextField?
    @IBOutlet var labelMessageOTP : UILabel?
    var user_id : String? = ""
    var mobileNumber : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldOTP?.becomeFirstResponder()
        labelMessageOTP?.text = "A One-Time Password has been sent to \(mobileNumber ?? "") , please enter OTP number."
        self.navigationController?.isNavigationBarHidden = false

        self.initialMethod()
        // Do any additional setup after loading the view.
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func submitButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (textFieldOTP?.text == nil ||  textFieldOTP?.text == ""){
            _ = AlertController.alert("Oops!", message: "OTP Field is Empty")
            return
        }
        if Connectivity.isConnectedToInternet {
           self.API_Calling_For_OTPVerify()
        }else{
            _ = AlertController.alert("Oops!", message: K_NoInternet)
        }
    }
    @IBAction func resendButtonAction(_ sender: UIButton) {
    
        if Connectivity.isConnectedToInternet {
             self.API_Calling_For_ResendOTP()
        }else{
            _ = AlertController.alert("Oops!", message: K_NoInternet)
        }
    }
    
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


extension OTPViewController {
    
    // MARK:- Helper Method
    func initialMethod() {
        
        self.navigationItem.leftBarButtonItem = AppUtility.leftBarButton("back", controller: self)
        self.navigationItem.title = "OTP Verification"
}
    //MARK: API Methods
    func API_Calling_For_OTPVerify() -> Void {
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
    
        
        let Item = ["user_id":user_id ?? "","user_mob": mobileNumber ?? "","otp": textFieldOTP?.text! ?? ""] as [String : Any]
        
        let url = kServer + KServerPath + K_VerifyAccount
        
        APIHelper.shared.callAPIPost(Item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.successData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert(K_Opps, message: K_SomethingWentWrong)
            }
        })
        
    }
    func API_Calling_For_ResendOTP() -> Void {
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
      
        
        let Item = ["user_id":user_id,"user_mob": mobileNumber ?? ""] as [String : Any]
        
        let url = kServer + KServerPath + K_ResendOTP
        
        APIHelper.shared.callAPIPost(Item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.successDataResendOTP(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert(K_Opps, message: K_SomethingWentWrong)
            }
        })
        
    }
    
    //MARK: Handle api response methods
    func successData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
        _ = AlertController.alert("", message: result["message"] as! String, controller: self, buttons: ["OK"], tapBlock: { (UIAlertAction, index) in
        self.navigationController?.popToRootViewController(animated: true)
            })
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }
        func successDataResendOTP(result : NSDictionary) {
            if let status = (result as AnyObject).value(forKey: "status") as? String {
                if status == "1" {
                    let message = (result as AnyObject).value(forKey: "message") as? String
                    _ = AlertController.alert("Alert!", message: message!)
                }else{
                    let message = (result as AnyObject).value(forKey: "message") as? String
                    _ = AlertController.alert("Alert!", message: message!)
                }
            }
    }

}
