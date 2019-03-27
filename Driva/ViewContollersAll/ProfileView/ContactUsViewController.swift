//
//  ContactUsViewController.swift
//  Layu
//
//  Created by Apple on 9/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import ASProgressHud

class ContactUsViewController: UIViewController {

    @IBOutlet weak var contactUsTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    var dataArray = [Dictionary<String, String>]()
    var userObj = UserInfo()
    var isEmptyMessage = Bool()

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
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if isAllFieldsVerified() {
            if Connectivity.isConnectedToInternet {
                API_Calling_For_ContactUs()
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
        self.navigationItem.title = "Feedback"
        
        dataArray = [["placeholderText":"Name","image":"account"], ["placeholderText":"E-mail","image":"email"], ["placeholderText":"Subject","image":"text-subject"]]
        isEmptyMessage = true
        userObj.messageStr = "Message"
        userObj.subject = ""
        
        let userInfo = UserDetail.shared.getUserInfo()
        let user_fullname = userInfo.value(forKey: UserKeys.user_fullname.rawValue) as! String
        let user_email = userInfo.value(forKey: UserKeys.user_email.rawValue) as! String

        userObj.full_name = user_fullname
        userObj.emailId = user_email

    }
    
    // Validation Method
    func isAllFieldsVerified() -> Bool {
        
        var isvalid = false
        
        if userObj.full_name.length == 0{
            userObj.errorMsg = "Please enter your name."
        }else if userObj.emailId.length == 0 {
            userObj.errorMsg = "Please enter email id."
        }else if !userObj.emailId.isEmail {
            userObj.errorMsg = "Please enter valid email id."
        }else if userObj.subject.length == 0 {
            userObj.errorMsg = "Please enter subject."
        }else if userObj.messageStr.length == 0 || isEmptyMessage {
            userObj.errorMsg = "Please enter message."
        }
        else {
            isvalid = true
        }
        return isvalid
    }
    
    // MARK:- Call Api method
    func API_Calling_For_ContactUs() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let Item = ["name":userObj.full_name, "email": userObj.emailId, "subject": userObj.subject, "message": userObj.messageStr]
        let url = kServer + KServerPath + K_ContactUSApi
        
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

extension ContactUsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCell") as! TextViewTableViewCell
            cell.addressTextView.delegate = self
            cell.addressTextView.text = userObj.messageStr
            cell.addressTextView.autocorrectionType = .no

            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePasswordTableViewCell") as! ChangePasswordTableViewCell
            let dict = dataArray[indexPath.row]
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row + 100
            cell.inputTextField.returnKeyType = indexPath.row == 2 ? .done : .next
            cell.inputTextField.keyboardType = indexPath.row == 1 ? .emailAddress : .default
            cell.inputTextField.autocapitalizationType = indexPath.row == 1 ? .none : .words
            cell.inputTextField.text = indexPath.row == 0 ? userObj.full_name : indexPath.row == 1 ? userObj.emailId : userObj.subject
            cell.inputTextField.autocorrectionType = .no
            cell.inputTextField.placeholder = dict["placeholderText"]

            cell.inputTextField.setValue(UIColor.black, forKeyPath: "_placeholderLabel.textColor")
            cell.iconImageView.image = UIImage.init(named: dict["image"]!)
            
            return cell
        }
    }
    
}

extension ContactUsViewController : UITextFieldDelegate {
    
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
        
        if str.length > 64 {
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 100 {
            userObj.full_name = textField.text!
        }else if textField.tag == 101 {
            userObj.emailId = textField.text!
        }else {
            userObj.subject = textField.text!
        }
    }
    
}

extension ContactUsViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isEmptyMessage {
            textView.text = ""
            userObj.messageStr = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            isEmptyMessage = true
            textView.text = "Message"
            userObj.messageStr = "Message"
        }else {
            userObj.messageStr = textView.text
            isEmptyMessage = false
        }
    }
    
}
