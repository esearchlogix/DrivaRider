//
//  PaymentCustomPopUpViewController.swift
//  Driva
//
//  Created by Manoj Singh on 28/09/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud
import GoogleMaps

protocol PaymentPopUpDelegate {
    func dismissPaymentPopUp(isStatus : Bool, isBookingSuccess : Bool, bookingPayId: String)
}

class PaymentCustomPopUpViewController: UIViewController,UIGestureRecognizerDelegate {

    var delegate: PaymentPopUpDelegate?
    @IBOutlet weak var workingView: UIView!
    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var drivaWalletButton: UIButton!
    @IBOutlet weak var walletBalaceLabel: UILabel!

    var isWallet = Bool()
    var bookingID = ""
    var price = ""
    var taxiID = ""
    var startCordinates = CLLocationCoordinate2D()
    var destinationCordinates = CLLocationCoordinate2D()
    var distance = ""
    var time = ""
    var comingFrom = ""
    var penaltystatus = ""
   
    var from_address = ""
    var to_address = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isWallet {
            cashButton.isSelected = false
            drivaWalletButton.isSelected = true
        }else {
            cashButton.isSelected = true
            drivaWalletButton.isSelected = false
        }
      
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self // This is not required
        self.view.addGestureRecognizer(tap)
        
        if Connectivity.isConnectedToInternet {
            self.API_Calling_For_GetWalletBalance()
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- IBAction Method
    @IBAction func commonButtonAction(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            self.isWallet = false
            cashButton.isSelected = true
            drivaWalletButton.isSelected = false
            break
        case 101:
            self.isWallet = true
            cashButton.isSelected = false
            drivaWalletButton.isSelected = true
            break
        case 102:
            self.dismiss(animated: false) {
                if (self.delegate != nil) {
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.dismissPaymentPopUp(isStatus: self.isWallet, isBookingSuccess: false, bookingPayId: "")
                }
            }
            break
        case 103:
            if Connectivity.isConnectedToInternet {
                if comingFrom == "Book Ride"{
                    self.API_Calling_For_BookRide()
                }else{
                    self.API_Calling_For_PayRide()

                }
            }else{
                _ = AlertController.alert("Alert!", message: K_NoInternet)
            }
            break
        default:
            dismiss(animated: false, completion: nil)
            break
        }
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
                self.successData(result: (JSON as? NSDictionary ?? [:]))
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })
        
    }
    
    func API_Calling_For_PayRide() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
      
       

        let item = ["user_id":userId, "booking_id":self.bookingID, "amount":self.price, "payment_method":isWallet ? "driva wallet" : "cash"] as [String : Any]
        
        let url = kServer + KServerPath + K_payRideApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.successPayRide(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })
        
    }
    
    func API_Calling_For_BookRide() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let distanceArray = self.distance.split(separator: " ")
        let timeArray = self.time.split(separator: " ")
        let distance = distanceArray.first
        let time = timeArray.first
        
        
        let item = ["user_id":userId, "taxi_type":self.taxiID, "from_lat":"\(self.startCordinates.latitude)", "from_lng":"\(self.startCordinates.longitude)", "to_lat":"\(self.destinationCordinates.latitude)", "to_lng":"\(self.destinationCordinates.longitude)", "duration":time!, "distance":distance!,"payment_method":isWallet ? "driva wallet" : "cash", "price":self.price,"penalty" : penaltystatus ,  "from_address" : self.from_address, "to_address" :  self.to_address] as [String : Any]
        
        let url = kServer + KServerPath + K_BookRideApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.successBookRide(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })
        
    }
    func successBookRide(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let bookingID = (result as AnyObject).value(forKey: "booking_id") as! Int
                self.dismiss(animated: false) {
                    if (self.delegate != nil) {
                        self.delegate?.dismissPaymentPopUp(isStatus: self.isWallet, isBookingSuccess: true, bookingPayId: "\(bookingID)")
                    }
                }
            }else{
               
                let message = (result as AnyObject).value(forKey: "message") as? String
                if message == "You not have enough money in your credit wallet to book this ride!"{
                    _ = AlertController.alert("Wallet Money", message: message!, controller: self, buttons: ["LATER", "ADD MONEY"]) { (UIAlertAction, index) in
                        
                        switch index {
                        case 1:
                            self.dismiss(animated: false) {
                                if (self.delegate != nil) {
                                    self.delegate?.dismissPaymentPopUp(isStatus: self.isWallet, isBookingSuccess: false, bookingPayId: "")
                                }
                            }
                            break
                        default :
                            break
                        }
                        
                    }
                }else{
                    _ = AlertController.alert("Alert!", message: message!, controller: self, buttons: ["OK"]) { (UIAlertAction, index) in
                        
                        
                            self.dismiss(animated: false) {
                                if (self.delegate != nil) {
                                    self.delegate?.dismissPaymentPopUp(isStatus: self.isWallet, isBookingSuccess: true, bookingPayId: "")
                                }
                            }
                        
                        
                    }
                }
             
            }
        }
    }
    
    // MARK:- Handle response of Api
    func successData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                if let balance = (result as AnyObject).value(forKey: "balance") as? String {
                    self.walletBalaceLabel.text = "Wallet Amount: \(balance) GH₵"
                }else{
                    _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
                }
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message  ?? "No Mobile Money")
            }
        }
    }
    
    func successPayRide(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                self.dismiss(animated: false) {
                    if (self.delegate != nil) {
                        self.delegate?.dismissPaymentPopUp(isStatus: self.isWallet, isBookingSuccess: true, bookingPayId: "\(status)")
                    }
                }
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!, controller: self, buttons: ["OK"]) { (UIAlertAction, index) in
                    self.dismiss(animated: false) {
                        if (self.delegate != nil) {
                            self.delegate?.dismissPaymentPopUp(isStatus: self.isWallet, isBookingSuccess: true, bookingPayId: "")
                        }
                    }
                }
            }
        }
    }
    
}
