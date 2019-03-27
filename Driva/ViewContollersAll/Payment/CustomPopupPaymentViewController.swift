//
//  CustomPopupPaymentViewController.swift
//  DRIVA
//
//  Created by Alekh Verma on 19/03/19.
//  Copyright © 2019 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud
import GoogleMaps


protocol PaymentModeDelegate {
    func dismissPaymentModePopUp(ishub: Bool)
}
class CustomPopupPaymentViewController: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var workingView: UIView!
   
    var delegate: PaymentModeDelegate?

    var rechargeAmount = ""
    var isFromBook = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self // This is not required
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: nil)
        // self.delegate?.dismissPaymentPopUp(isStatus: self.isWallet, isBookingSuccess: false, bookingPayId: "")
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if workingView.bounds.contains(touch.location(in: workingView)) {
            return false
        }
        return true
    }
    @IBAction func commonButtonAction(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            if Connectivity.isConnectedToInternet {
                self.dismiss(animated: false) {
                    if (self.delegate != nil) {
                        self.dismiss(animated: true, completion: nil)
                        self.delegate?.dismissPaymentModePopUp(ishub: false)
                    }
                }            }else{
                _ = AlertController.alert("Alert!", message: K_NoInternet)
            }
            break
        case 101:
            if Connectivity.isConnectedToInternet {
                self.dismiss(animated: false) {
                    if (self.delegate != nil) {
                        self.dismiss(animated: true, completion: nil)
                        self.delegate?.dismissPaymentModePopUp(ishub: true)
                    }
                }            }else{
                _ = AlertController.alert("Alert!", message: K_NoInternet)
            }
            break
       
        default:
            dismiss(animated: false, completion: nil)
            break
        }
    }
    
    // MARK:- Call Api method
    func API_Calling_For_RechargeWallet() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["user_id":userId, "amount":rechargeAmount, "payment_type":"test"]
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
        
        let item = ["user_id":userId, "amount":rechargeAmount, "payment_type":"live"]
        let url = kServer + KServerPath +  K_HubtelWalletApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesDataHublet(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })
        
    }
    
    func succeesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                if let checkouturl = (result as AnyObject).value(forKey: "checkouturl") as? String {
                    let openUrlVC = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageViewController") as! StaticPageViewController
                    openUrlVC.index = 2
                    openUrlVC.openUrlStr = checkouturl
                    openUrlVC.isFromBookingRide = isFromBook
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
                    openUrlVC.index = 2
                    openUrlVC.isHubtle = true
                    openUrlVC.checkoutID = (result as AnyObject).value(forKey: "checkoutId") as? String ?? ""
                    openUrlVC.openUrlStr = checkouturl
                    openUrlVC.isFromBookingRide = isFromBook
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
