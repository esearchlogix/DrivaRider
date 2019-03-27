//
//  myProfileViewController.swift
//  Driva
//
//  Created by mediatrenz on 10/09/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud
import MobileCoreServices

class myProfileViewController: UIViewController {

    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var MobileTxt: UITextField!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var emailidTxt: UITextField!
    @IBOutlet weak var aboutTxt: UITextField!
    @IBOutlet weak var userViewbg: UIView!
    @IBOutlet weak var emailBgView: UIView!
    @IBOutlet weak var aboutBgView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var showCuntryCodeBGView: UIView!

    var CounteryShortName = String()
    var CodeAddOnButton = String()
    var countryCodeArry:Array<AnyObject>! = Array<AnyObject>()
    var CountryCodeDict:NSDictionary = [:]
    var arrSearch =  Array<AnyObject>()
    var dataArray = Array<AnyObject>()

    // MARK:- ViewController Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNames()
        ViewDidLordItemCall()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func CuntryCodeBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.showCuntryCodeBGView.isHidden = false
    }
    
    @IBAction func profileButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        openPickerSheet()
    }
    
    @IBAction func updateButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if (fullName.text == nil || fullName.text == "") {
            PDAlert.shared.showAlertWith("Alert!", message: "FullName is Empty!", onVC: self)
            return
        }
        if (MobileTxt.text == nil ||  MobileTxt.text == ""){
            PDAlert.shared.showAlertWith("Alert!", message: "Mobile Number is Empty!", onVC: self)
            return
        }
        
        let sliced = String(CodeAddOnButton.dropFirst())
        let CountryCodeAndMobile = "\(sliced)-\(MobileTxt.text!)"
        if Connectivity.isConnectedToInternet {
            let userInfo = UserDetail.shared.getUserInfo()
            let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String

            self.Api_UserEditProfile(fullName.text!, MobileNub: CountryCodeAndMobile, UserId: userId, About: aboutTxt.text ?? "")
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }

    }
    
    func ViewDidLordItemCall() -> Void {
        
        let leftButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        leftButton.setImage(#imageLiteral(resourceName: "log"), for: .normal)
        leftButton.contentMode = .scaleAspectFill
        leftButton.isUserInteractionEnabled = false
        
        self.navigationItem.leftBarButtonItems = [AppUtility.leftBarButton("back", controller: self), UIBarButtonItem.init(customView: leftButton)]
        self.navigationItem.title = "My Profile"

        self.showCuntryCodeBGView.isHidden = true
        self.updateButton.layer.cornerRadius = 8
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userImage = UserDetail.shared.getUserImage()
        let userName = userInfo.value(forKey: UserKeys.user_fullname.rawValue) as! String
        let userEmailId = userInfo.value(forKey: UserKeys.user_email.rawValue) as! String
        let about = userInfo.value(forKey: UserKeys.about.rawValue) as? String

        
        let userMobileNumber = userInfo.value(forKey: UserKeys.user_mob.rawValue) as! String
        let mobileArray = userMobileNumber.split(separator: "-")

        self.profileButton.sd_setImage(with: URL.init(string: userImage), for: .normal, placeholderImage: #imageLiteral(resourceName: "download"))

        emailidTxt.setLeftPaddingPoints(10)
        emailBgView.addViewBottomBorderWithColor(color: UIColor.black, width: 1)
        emailidTxt.text = userEmailId
        
        aboutTxt.setLeftPaddingPoints(10)
        aboutBgView.addViewBottomBorderWithColor(color: UIColor.black, width: 1)
        aboutTxt.text = about
        
        fullName.setLeftPaddingPoints(10)
        userViewbg.addViewBottomBorderWithColor(color: UIColor.black, width: 1)
        fullName.text = userName

        MobileTxt.setLeftPaddingPoints(10)
        MobileTxt.addBottomBorderWithColor(color: UIColor.black, width: 1)
        MobileTxt.text = String(mobileArray.last!)
        
        let country = countryCodeArry.filter { $0["dial_code"] as! String == ("+" + String(mobileArray.first!))}
        let countryDict = country.first
        let CountryCodeName = countryDict!["code"] as! String
        let CountryCode = countryDict!["dial_code"] as! String
        CodeAddOnButton = CountryCode
        self.countryCodeBtn.setTitle("(\(CountryCodeName)) \(CountryCode)", for: .normal)
    }
    
    func gotoLoginPage(){
        self.view.endEditing(true)
        let storyBord : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBord.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    func openPickerSheet() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraBtn: UIAlertAction = UIAlertAction(title: "Take Photo", style: .default) { action -> Void in
            self.selectImageFromCamera()
        }
        let photoBtn: UIAlertAction = UIAlertAction(title: "Choose Photo", style: .default) { action -> Void in
            self.selectImageFromGallery()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cameraBtn)
        actionSheetController.addAction(photoBtn)
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
        
    }

    fileprivate func loadNames() {
        if let filePath = Bundle.main.path(forResource: "countries", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: filePath) {
                let json = try? JSONSerialization.jsonObject(with: jsonData as Data, options: [])
                countryCodeArry = (json! as! NSArray) as Array<AnyObject>
                self.arrSearch.removeAll()
                self.dataArray.append(contentsOf: self.countryCodeArry)
                self.arrSearch.append(contentsOf: self.countryCodeArry)
            }
        }
    }

    /////API Calling
    func Api_UserEditProfile(_ FullName: String, MobileNub: String , UserId: String , About : String) {
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let item = ["user_name":FullName,"user_mob":MobileNub,"user_id":UserId,"about": About]
        let url = kServer + KServerPath + K_UserEditProfileApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                PDAlert.shared.showAlertWith("Alert!", message: K_SomethingWentWrong, onVC: self)
            }
        })
    }
    
    func Api_EditImage(){
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let Items = ["user_id":userId]
        let imgData1 = UIImageJPEGRepresentation((profileButton.imageView?.image)!, 0.2)!
        
        let url = kServer + KServerPath + K_EditImageApi
        
        APIHelper.shared.callAPIForUpload(Items, sUrl: url, imgData: imgData1, imageKey: "file") { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.saveProfileImage(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        }
        
    }
    
//MARK:- Handle response of Api
    func saveProfileImage(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = UserDetail.shared.setUserImage(message!)
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }
    
    func succeesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let messag = Parser.shared.getStringFrom(data: result, key: "message")
                let userInfo = Parser.shared.getAnyObjectFrom(data: (result as AnyObject), key: "user_info")
                _ = UserDetail.shared.setUserInfo(userInfo)
                PDAlert.shared.showAlerForActionWith(title: "Alert!", msg: messag, yes: "Ok", onVC: self){
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                let messag = Parser.shared.getStringFrom(data: result, key: "message")
                PDAlert.shared.showAlertWith("Alert!", message: messag, onVC: self)
            }
        }
    }
    
}

//MARK: TableView Datasource & Delegate Methods
extension myProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
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

extension myProfileViewController : UITextFieldDelegate {
    
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
        
        if textField == aboutTxt{
            if textField.text?.count ?? 0 > 250{
                if string == ""{
                    return true
                }
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 100 {
        }else if textField.tag == 101 {
        }else {
        }
    }
    
}

extension myProfileViewController : UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    func selectImageFromGallery() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imag.mediaTypes = [kUTTypeImage as String];
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }
    
    func selectImageFromCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.camera;
            imag.mediaTypes = [kUTTypeImage as String];
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismiss(animated: true) {
            DispatchQueue.main.async(execute: {
                _ = AlertController.alert("Alert!", message: "Are you sure? You want to save this image as Profile photo.", controller: self, buttons: ["YES", "NO"]) { (UIAlertAction, index) in
                    switch index {
                    case 0:
                        self.profileButton.setImage(chosenImage, for: .normal)
                        if Connectivity.isConnectedToInternet {
                            self.Api_EditImage()
                        }else{
                            _ = AlertController.alert("Alert!", message: K_NoInternet)
                        }
                        break
                    default :
                        break
                    }
                }
            })
        }
    }
    
}


