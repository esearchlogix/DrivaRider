//
//  profileViewController.swift
//  Driva
//
//  Created by mediatrenz on 27/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import SDWebImage
import ASProgressHud

class profileViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var itemsArry = Array<AnyObject>()
    
    // MARK:- ViewController Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.separatorStyle = .none
        itemsArry = ["My Profile","Change password","Terms and Conditions","Privacy Policy","Feedback","Log Out"] as [AnyObject]
        
        self.navigationItem.leftBarButtonItem = AppUtility.leftBarButton("menu", controller: self)
//        self.navigationItem.rightBarButtonItem = AppUtility.rightBarButton("notification", controller: self)

        let titleView = UIButton.init(frame: CGRect(x: 10, y: 0, width: 35, height: 40))
        titleView.setImage(#imageLiteral(resourceName: "log"), for: .normal)
        titleView.contentMode = .center
        titleView.isUserInteractionEnabled = false
        self.navigationItem.titleView = titleView

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userInfo = UserDetail.shared.getUserInfo()
        let userName = userInfo.value(forKey: UserKeys.user_fullname.rawValue) as! String
        let userImage = UserDetail.shared.getUserImage()
        userNameLabel.text = userName
        userImageView.sd_setImage(with: URL.init(string: userImage), placeholderImage: #imageLiteral(resourceName: "download"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        self.view.endEditing(true)
        if let slideMenuController = self.slideMenuController() {
            slideMenuController.openLeft()
        }
    }
    
//    @objc func rightBarButtonAction(_ button : UIButton) {
//        self.view.endEditing(true)
//    }
    
}

extension profileViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
        
        cell.TitelLib.text! = itemsArry[indexPath.row] as! String
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let myProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "myProfileViewController") as! myProfileViewController
            self.navigationController?.pushViewController(myProfileVC, animated: true)
            break
        case 1:
            let changePasswordVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            self.navigationController?.pushViewController(changePasswordVC, animated: true)
            break
        case 2:
            let termsConditionVC = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageViewController") as! StaticPageViewController
            termsConditionVC.index = 0
            self.navigationController?.pushViewController(termsConditionVC, animated: true)
            break
        case 3:
            let privacyPolicyVC = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageViewController") as! StaticPageViewController
            privacyPolicyVC.index = 1
            self.navigationController?.pushViewController(privacyPolicyVC, animated: true)
            break
        case 4:
            let contactUsVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            self.navigationController?.pushViewController(contactUsVC, animated: true)
            break
        default:
            PDAlert.shared.showAlerForActionWithNo(title:  "Alert!", msg: "Are you sure you want to Log Out?", yes: "Yes", no: "No", onVC: self) {
                if Connectivity.isConnectedToInternet {
                    self.API_Calling_For_DeleteToken()
                }else{
                    _ = AlertController.alert("Alert!", message: K_NoInternet)
                }
            }
            break
        }
        
    }
    
}

class ProfileTableViewCell : UITableViewCell {
    @IBOutlet weak var TitelLib: UILabel!
    
}

extension profileViewController {
    
    // MARK:- Call Api method
    func API_Calling_For_DeleteToken() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String

        let Item = ["user_id":userId, "device_token": "\(UserDefaults.standard.getToken() ?? "")"]
        let url = kServer + KServerPath + K_DeleteTokenApi
        
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
                DispatchQueue.main.async {
                    _ = UserDetail.shared.setUserLogin(false)
                    let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate
                    APPDELEGATE.loadLoginView()
//                    let stroryBord: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                    let fastFoodRestaurant = stroryBord.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//                    self.navigationController?.pushViewController(fastFoodRestaurant, animated: false)
                }
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }

}
