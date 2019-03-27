//
//  forgetPwdViewController.swift
//  Driva
//
//  Created by mediatrenz on 23/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud

class forgetPwdViewController: UIViewController {

    @IBOutlet weak var emailBgview: UIView!
    @IBOutlet weak var forgetpassword: UIButton!
    @IBOutlet weak var emailTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationController?.isNavigationBarHidden = true
        ViewDidLordItemCall()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    @IBAction func backBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func ForgotPasswordAction(_ sender: UIButton) {
        
        if (emailTxt.text == nil ||  emailTxt.text == ""){
            PDAlert.shared.showAlertWith("Oops!", message: "Please enter a email address", onVC: self)
            return
        }
        if Connectivity.isConnectedToInternet {
            API_Calling_For_Forgotpassword()
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }
    }
    
func API_Calling_For_Forgotpassword() -> Void {
    
    _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        let Item = ["email":emailTxt.text!]
        let url = NearLoginUrlStruct().URL_FORGET
        APIHelper.shared.callAPIPost(Item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.SucceesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                PDAlert.shared.showAlertWith("Alert!", message: "Unable to Send Email Server.", onVC: self)
            }
        })
    }
    
    func SucceesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let messag = Parser.shared.getStringFrom(data: result, key: "message")
                PDAlert.shared.showAlerForActionWith(title: "Alert!", msg: messag, yes: "Ok", onVC: self){
                    self.view.endEditing(true)
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                PDAlert.shared.showAlertWith("Alert!", message: message, onVC: self)
            }
        }
    }
    fileprivate func gotoHomePage()
    {
        let storyBord : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBord.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
 
}

extension forgetPwdViewController {
    func ViewDidLordItemCall() -> Void {

        self.forgetpassword.layer.cornerRadius = 8
        emailTxt.setLeftPaddingPoints(10)
        emailBgview.addViewBottomBorderWithColor(color: UIColor.black, width: 1)

    }
    
}
