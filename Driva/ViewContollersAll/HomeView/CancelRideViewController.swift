//
//  CancelRideViewController.swift
//  DrivaPartner
//
//  Created by Manoj Singh on 19/11/18.
//  Copyright © 2018 Manoj Singh. All rights reserved.
//

import UIKit
import ASProgressHud

class CancelRideViewController: UIViewController {

    @IBOutlet weak var driverDeniedDutyButton: UIButton!
    @IBOutlet weak var unableToContactDriverButton: UIButton!
    @IBOutlet weak var driverMisbehaveButton: UIButton!
    @IBOutlet weak var myReasonNotListedButton: UIButton!

    var bookingID = ""
    var reasonStr = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }
    
    // MARK:- IBAction Method
    @IBAction func dontCancelButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonAction(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet {
            self.Api_CancelRide(reason: self.reasonStr)
        }else{
            _ = AlertController.alert(K_Opps, message: K_NoInternet)
        }
    }

    @IBAction func commonButtonAction(_ sender: UIButton) {
        
        self.driverDeniedDutyButton.isSelected = false
        self.unableToContactDriverButton.isSelected = false
        self.driverMisbehaveButton.isSelected = false
        self.myReasonNotListedButton.isSelected = false

        switch sender.tag {
        case 100:
            self.driverDeniedDutyButton.isSelected = true
            self.reasonStr = "Driver denied duty"

            break
        case 101:
            self.unableToContactDriverButton.isSelected = true
            self.reasonStr = "Unable to contact driver"
            break
        case 102:
            self.driverMisbehaveButton.isSelected = true
            self.reasonStr = "Driver misbehave"
            break
        case 103:
            self.myReasonNotListedButton.isSelected = true
            self.reasonStr = "My reason is not listed"
            break
        default:
            break
        }
    }

}

extension CancelRideViewController {
    
    // MARK:- Helper Method
    func initialMethod() {
        self.reasonStr = "Driver denied duty"

    }
    
    // MARK:- Call Api method
    func Api_CancelRide(reason : String) {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String

        let item = ["user_id":userId, "booking_id":self.bookingID, "reason":reason]
        let url = kServer + KServerPath + K_CancelRideApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                PDAlert.shared.showAlertWith("Alert!", message: K_SomethingWentWrong, onVC: self)
            }
        })
    }
    
    // MARK:- Handle response of Api
    func succeesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                _ = AlertController.alert("", message: result["message"] as! String, controller: self, buttons: ["OK"], tapBlock: { (UIAlertAction, index) in
                    self.dismiss(animated: true, completion: {
                        self.gotoHomePage()
                    })
                })
            }else{
                _ = AlertController.alert("", message: result["message"] as! String, controller: self, buttons: ["OK"], tapBlock: { (UIAlertAction, index) in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }

    fileprivate func gotoHomePage()
    {
        APPDELEGATE.loadMenu()
    }

}
