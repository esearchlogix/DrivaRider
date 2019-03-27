//
//  signUpViewController.swift
//  Driva
//
//  Created by mediatrenz on 23/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud

class signUpViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var MobileTxt: UITextField!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var aboutTxt: UITextField!
    @IBOutlet weak var emailidTxt: UITextField!
    
    @IBOutlet weak var userViewbg: UIView!
    @IBOutlet weak var emailBgView: UIView!
    @IBOutlet weak var passwordViewBg: UIView!
    @IBOutlet weak var aboutViewBg: UIView!
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var showCuntryCodeBGView: UIView!
    var CounteryShortName = String()
    var CodeAddOnButton = String()
    
    
    var countryCodeArry:Array<AnyObject>! = Array<AnyObject>()
    var CountryCodeDict:NSDictionary = [:]
    var arrSearch =  Array<AnyObject>()
    var dataArray = Array<AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationController?.isNavigationBarHidden = true
        
        ViewDidLordItemCall()
        loadNames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func BackBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func CuntryCodeBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.showCuntryCodeBGView.isHidden = false
    }

    fileprivate func loadNames() {
        if let filePath = Bundle.main.path(forResource: "countries", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: filePath) {
                let json = try? JSONSerialization.jsonObject(with: jsonData as Data, options: [])
                countryCodeArry = (json! as! NSArray) as Array<AnyObject>
                self.arrSearch.removeAll()
                self.dataArray.append(contentsOf: self.countryCodeArry)
                self.arrSearch.append(contentsOf: self.countryCodeArry)
                //debugPrint(arrSearch)
            }
        }
    }

    @IBAction func signUpBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        if (fullName.text == nil || fullName.text == "") {
            PDAlert.shared.showAlertWith("Warning!", message: "FullName is Empty!", onVC: self)
            return
           }
        if (emailidTxt.text == nil ||  emailidTxt.text == ""){
            PDAlert.shared.showAlertWith("Warning!", message: "Email is Empty!", onVC: self)
            return
        }
        if !(emailidTxt.text?.isValidEmail)!{
            PDAlert.shared.showAlertWith("Message", message: "Please enter a valid email address", onVC: self)
            return
        }
        if (passwordTxt.text == nil ||  passwordTxt.text == ""){
            PDAlert.shared.showAlertWith("Warning!", message: "Password is Empty!", onVC: self)
            return
        }
        if (MobileTxt.text == nil ||  MobileTxt.text == ""){
            PDAlert.shared.showAlertWith("Warning!", message: "Mobile Number is Empty!", onVC: self)
            return
        }
        
        let sliced = String(CodeAddOnButton.dropFirst())
        let CountryCodeAndMobile = "\(sliced)-\(MobileTxt.text!)"
        
        if Connectivity.isConnectedToInternet {
            newUserRegistration(fullName.text!, Email: emailidTxt.text!, Password: passwordTxt.text!, MobileNub: CountryCodeAndMobile, About: aboutTxt.text ?? "")
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }

    }

/////API Calling
    func newUserRegistration(_ FullName: String, Email: String, Password: String, MobileNub: String,About : String ) {
    _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        let item = ["user_name":FullName,"user_email":Email,"user_pwd":Password,"user_mob":MobileNub,"user_type":"User","about":About]
    let url = NearLoginUrlStruct().URL_RIGISTER
    APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
        _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
        if let JSON = response{
            self.registrationSucceesData(result: (JSON as? NSDictionary) ?? [:], mobileNum: MobileNub)
        }else{
            PDAlert.shared.showAlertWith("Alert!", message: "Registration failed.", onVC: self)
        }
    })
}
    
func registrationSucceesData(result : NSDictionary, mobileNum : String ) {
    if let status = (result as AnyObject).value(forKey: "status") as? String {
        if status == "1" {
            
            let otpVerificationVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
            otpVerificationVC.user_id = "\((result as AnyObject).value(forKey: "user_id") as? Int ?? 0)"
            otpVerificationVC.mobileNumber = mobileNum
            self.navigationController?.pushViewController(otpVerificationVC, animated: true)
            let messag = Parser.shared.getStringFrom(data: result, key: "message")
            
//            PDAlert.shared.showAlerForActionWith(title: "Alert!", msg: messag, yes: "Ok", onVC: self){
//                self.view.endEditing(true)
//                self.navigationController?.popViewController(animated: true)
//            }
        }else{
            let messag = Parser.shared.getStringFrom(data: result, key: "message")
            PDAlert.shared.showAlertWith("Alert!", message: messag, onVC: self)
        }
    }
}

func gotoLoginPage(){
    self.view.endEditing(true)
    let storyBord : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextViewController = storyBord.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    self.navigationController?.pushViewController(nextViewController, animated: true)
    
}
 
//MARK: TableView For CutntryCode/////////////////////////////////////////////////////////
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearch.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "codeCell") as! CountryCodeTableviewCell
        cell.selectionStyle = .none
        CountryCodeDict = countryCodeArry[indexPath.row] as! NSDictionary
        let CountryName = CountryCodeDict["name"] as! String
        let CountryCodeName = CountryCodeDict["code"] as! String
        cell.CountryNameLib.text! = "\(CountryName)  \((CountryCodeName))"
        cell.codeLib.text! = CountryCodeDict["dial_code"] as! String
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.cellForRow(at: indexPath) as! CountryCodeTableviewCell
        CountryCodeDict = countryCodeArry[indexPath.row] as! NSDictionary
        let CountryCodeName = CountryCodeDict["code"] as! String
        let CountryCode = CountryCodeDict["dial_code"] as! String
        CodeAddOnButton = CountryCode
        self.countryCodeBtn.setTitle("(\(CountryCodeName)) \(CountryCode)", for: .normal)
        showCuntryCodeBGView.isHidden =  true
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
}

class CountryCodeTableviewCell: UITableViewCell {
    @IBOutlet weak var CountryNameLib: UILabel!
    @IBOutlet weak var codeLib: UILabel!
}

extension signUpViewController {
    func ViewDidLordItemCall() -> Void {
        
        self.showCuntryCodeBGView.isHidden = true
        self.signUpBtn.layer.cornerRadius = 8
        
        emailidTxt.setLeftPaddingPoints(10)
        emailBgView.addViewBottomBorderWithColor(color: UIColor.black, width: 1)
        
        passwordTxt.setLeftPaddingPoints(10)
        passwordViewBg.addViewBottomBorderWithColor(color: UIColor.black, width: 1)
        
        aboutTxt.setLeftPaddingPoints(10)
        aboutViewBg.addViewBottomBorderWithColor(color: UIColor.black, width: 1)

        
        fullName.setLeftPaddingPoints(10)
        userViewbg.addViewBottomBorderWithColor(color: UIColor.black, width: 1)
        
        MobileTxt.setLeftPaddingPoints(10)
        MobileTxt.addBottomBorderWithColor(color: UIColor.black, width: 1)

    }
    
}

extension signUpViewController : UITextFieldDelegate {
    
    // MARK:- TextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if textField == aboutTxt{
            if textField.text?.count ?? 0 > 250{
                return false
            }
        }
        
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        
        var searchS = ""
        if string == "" {
            
            if textField.text!.count > 0 {
                let index1 = textField.text!.index(textField.text!.endIndex, offsetBy: -1)
                searchS = String(textField.text![textField.text!.startIndex..<index1])
            }
        } else {
            searchS = textField.text! + string
        }
        
        let predicate = NSPredicate(format: "name contains[c] %@", searchS)
//        print("text => \(predicate)")
        if searchS == "" {
            arrSearch = dataArray
        }else {
            arrSearch = dataArray.filter{ ($0["name"] as! String).range(of: searchS, options: [.diacriticInsensitive, .caseInsensitive]) != nil }
        }
       
        countryCodeArry = arrSearch
        self.mainTableView.reloadData()
        
        return true
    }
    
}
