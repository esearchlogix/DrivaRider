//
//  ChangePasswordViewController.swift
//  Layu
//
//  Created by Apple on 9/6/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import ASProgressHud

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var changePasswordTableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!

    var dataArray = [Dictionary<String, String>]()
    var userObj = UserInfo()
    
    // MARK:- ViewController Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialMethod()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if isAllFieldsVerified() {
            if Connectivity.isConnectedToInternet {
                API_Calling_For_ChangePassword()
            }else{
                _ = AlertController.alert("Alert!", message: K_NoInternet)
            }
        }else{
            _ = AlertController.alert("Alert!", message: userObj.errorMsg)
        }

    }
    
    // MARK:- Helper Method
    func initialMethod() {
        
        let leftButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        leftButton.setImage(#imageLiteral(resourceName: "log"), for: .normal)
        leftButton.contentMode = .scaleAspectFill
        leftButton.isUserInteractionEnabled = false
        
        self.navigationItem.leftBarButtonItems = [AppUtility.leftBarButton("back", controller: self), UIBarButtonItem.init(customView: leftButton)]
        self.navigationItem.title = "Change Password"
        
        dataArray = [["placeholderText":"Old Password","image":"lock"], ["placeholderText":"New Password","image":"lock"], ["placeholderText":"Confirm Password","image":"lock"]]
    }
    
    // Validation Method
    func isAllFieldsVerified() -> Bool {
        
        var isvalid = false
        
        if userObj.password.length == 0{
            userObj.errorMsg = "Please enter your old password."
        }else if userObj.newPassword.length == 0 {
            userObj.errorMsg = "Please enter new password."
        }else if userObj.newPassword != userObj.confirmPassword {
            userObj.errorMsg = "Password and confirm password must be same."
        }
        else {
            isvalid = true
        }
        return isvalid
    }

    // MARK:- Call Api method
    func API_Calling_For_ChangePassword() -> Void {

        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String

        let Item = ["user_id":userId, "old_pass": userObj.password, "new_pass": userObj.newPassword] as [String : Any]
        let url = kServer + KServerPath + K_ChangePasswordApi

        APIHelper.shared.callAPIPost(Item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })

    }
    
    // MARK:- Handle response of Api
    func succeesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                _ = AlertController.alert("", message: result["message"] as! String, controller: self, buttons: ["OK"], tapBlock: { (UIAlertAction, index) in
                    self.navigationController?.popViewController(animated: true)
                })
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }

}

extension ChangePasswordViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePasswordTableViewCell") as! ChangePasswordTableViewCell
        let dict = dataArray[indexPath.row]
        cell.inputTextField.delegate = self
        cell.inputTextField.tag = indexPath.row + 100
        cell.inputTextField.isSecureTextEntry = true
        cell.inputTextField.placeholder = dict["placeholderText"]
        cell.iconImageView.image = UIImage.init(named: dict["image"]!)
        cell.inputTextField.returnKeyType = indexPath.row == 2 ? .done : .next
        cell.inputTextField.autocorrectionType = .no

        return cell
        
    }
    
}

extension ChangePasswordViewController : UITextFieldDelegate {
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
        
        if str.length > 16 {
            return false
        }

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 100 {
            userObj.password = textField.text!
        }else if textField.tag == 101 {
            userObj.newPassword = textField.text!
        }else {
            userObj.confirmPassword = textField.text!
        }
    }
    
}
