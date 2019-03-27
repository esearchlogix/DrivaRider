//
//  AddMoneyViewController.swift
//  Driva
//
//  Created by Manoj Singh on 01/10/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud

protocol AddMoneyDelegate {
    func showPaymentCustomPopUp(isWallet : Bool)
}

class AddMoneyViewController: UIViewController {

    var delegate: AddMoneyDelegate?
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var addMoneyButton: UIButton!
    
    var isFromBookRideVC = Bool()
    var isWallet = Bool()

    // MARK:- ViewController Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        self.view.endEditing(true)
        if isFromBookRideVC {
            if (self.delegate != nil) {
                self.navigationController?.popViewController(animated: true)
                self.delegate?.showPaymentCustomPopUp(isWallet: self.isWallet)            }
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func addMoneyButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (inputTextField.text?.count)! > 0 {
            if (inputTextField.text?.isValidNumber())! {
                let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomPopupPaymentViewController") as!  CustomPopupPaymentViewController
                popUpVC.rechargeAmount = inputTextField.text ?? "0"
                popUpVC.isFromBook = isFromBookRideVC
                popUpVC.delegate = self
                popUpVC.modalTransitionStyle = .crossDissolve
                popUpVC.modalPresentationStyle = .overCurrentContext
                present(popUpVC, animated: false, completion: nil)
            }else {
                _ = AlertController.alert("Please enter valid amount.")
            }
        }else {
            _ = AlertController.alert("Please enter amount.")
        }
    }
    @IBAction func addHubtelButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (inputTextField.text?.count)! > 0 {
            if (inputTextField.text?.isValidNumber())! {
                if Connectivity.isConnectedToInternet {
                    self.API_Calling_For_HubtelWallet()
                }else{
                    _ = AlertController.alert("Alert!", message: K_NoInternet)
                }
            }else {
                _ = AlertController.alert("Please enter valid amount.")
            }
        }else {
            _ = AlertController.alert("Please enter amount.")
        }
    }
    
    
    
    // MARK:- Helper Method
    func initialMethod() {
        if Connectivity.isConnectedToInternet {
            self.API_Calling_For_GetWalletBalance()
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }
        mainView.aroundShadow()
        inputTextField.becomeFirstResponder()
        let leftTitle = UILabel.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        leftTitle.text = "Add Amount"
        self.navigationItem.leftBarButtonItems = [AppUtility.leftBarButton("back", controller: self), UIBarButtonItem.init(customView: leftTitle)]
    }
    
    // MARK:- Call Api method
    func API_Calling_For_GetWalletBalance() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["user_id":userId]
        let url = kServer + KServerPath + K_GetCashWalletBalanceApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesGetWalletData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })
        
    }
    
    // MARK:- Call Api method
    func API_Calling_For_RechargeWallet() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["user_id":userId, "amount":inputTextField.text!, "payment_type":"test"]
        let url = kServer + KServerPath + K_RechargeWalletApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })
        
    }
    func API_Calling_For_HubtelWallet() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["user_id":userId, "amount":inputTextField.text!, "payment_type":"live"]
        let url = kServer + KServerPath + K_HubtelWalletApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesDataHublet(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })
        
    }
    
    // MARK:- Handle response of Api
    func succeesGetWalletData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                if let balance = (result as AnyObject).value(forKey: "balance") as? String {
                    self.balanceLabel.text = "Available Balance: \(balance) GH₵"
                }else{
                    _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
                }
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }
    func succeesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                if let checkouturl = (result as AnyObject).value(forKey: "checkouturl") as? String {
                    let openUrlVC = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageViewController") as! StaticPageViewController
                    openUrlVC.delegate = self
                    openUrlVC.index = 2
                    openUrlVC.openUrlStr = checkouturl
                    openUrlVC.isFromBookingRide = isFromBookRideVC
                    openUrlVC.isHubtle = false
                    self.navigationController?.pushViewController(openUrlVC, animated: true)
                }else{
                    _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
                }
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }
    

    func succeesDataHublet(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                if let checkouturl = (result as AnyObject).value(forKey: "checkouturl") as? String {
                    let openUrlVC = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageViewController") as! StaticPageViewController
                    openUrlVC.delegate = self
                    openUrlVC.index = 2
                    openUrlVC.isHubtle = true
                    openUrlVC.checkoutID = (result as AnyObject).value(forKey: "checkoutId") as? String ?? ""
                    openUrlVC.openUrlStr = checkouturl
                    openUrlVC.isFromBookingRide = isFromBookRideVC
                    self.navigationController?.pushViewController(openUrlVC, animated: true)
                }else{
                    _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
                }
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }
    
}

extension AddMoneyViewController : UITextFieldDelegate {
    // MARK:- TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            let txtField = view.viewWithTag(textField.tag + 1) as? UITextField
            txtField?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }else if str  == " " {
            return false
        }
        
        return true
    }
    
}

extension AddMoneyViewController : ShowPaymentPopUpDelegate {
    
    func showPopUp() {
        if (self.delegate != nil) {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.showPaymentCustomPopUp(isWallet: self.isWallet)
        }
    }
}
extension AddMoneyViewController : PaymentModeDelegate {
    func dismissPaymentModePopUp(ishub: Bool) {
        if ishub ==  true{
            if Connectivity.isConnectedToInternet {
                self.API_Calling_For_HubtelWallet()
            }else{
                _ = AlertController.alert("Alert!", message: K_NoInternet)
            }
        }else{
            if Connectivity.isConnectedToInternet {
                self.API_Calling_For_RechargeWallet()
            }else{
                _ = AlertController.alert("Alert!", message: K_NoInternet)
            }
        }
    }
    


}
