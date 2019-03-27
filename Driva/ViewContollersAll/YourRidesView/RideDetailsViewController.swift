//
//  RideDetailsViewController.swift
//  Driva
//
//  Created by Manoj Singh on 20/11/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud

class RideDetailsViewController: UIViewController {
    
    @IBOutlet weak var rideDetailsTableView: UITableView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var fairView: UIView!
    @IBOutlet weak var paymentTypeView: UIView!
    @IBOutlet weak var profileTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fairLabel: UILabel!
        
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var okButtonHeightCons: NSLayoutConstraint!
    
    var bookingID = ""
    var isFinish = Bool()

    var bookingObj = BookingDetailsInfoModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        if isFinish {
            self.gotoHomePage()
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func okButtonAction(_ sender: UIButton) {
//        self.gotoHomePage()
                let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentCustomPopUpViewController") as!  PaymentCustomPopUpViewController
                popUpVC.delegate = self
                popUpVC.bookingID = bookingObj.booking_id
                popUpVC.price = bookingObj.price
                popUpVC.modalTransitionStyle = .crossDissolve
                popUpVC.modalPresentationStyle = .overCurrentContext
                present(popUpVC, animated: true, completion: nil)
    }
    
}
extension RideDetailsViewController : UIPopoverPresentationControllerDelegate{
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
extension RideDetailsViewController {
    
    // MARK:- Helper Method
    func initialMethod() {

       self.navigationItem.leftBarButtonItem = AppUtility.leftBarButton("back", controller: self)
        self.navigationItem.title = "Total Billing"
        self.navigationItem.hidesBackButton =  true
        if isFinish {
            self.okButtonHeightCons.constant = 56
        }else {
            self.okButtonHeightCons.constant = 0
        }

        self.profileView.aroundShadow()
        self.fairView.aroundShadow()
        self.paymentTypeView.aroundShadow()
        
        if Connectivity.isConnectedToInternet {
            self.Api_GetBookingDetailsApi()
        }else {
            PDAlert.shared.showAlertWith(K_Opps, message: K_NoInternet, onVC: self)
        }

    }

    fileprivate func gotoHomePage()
    {
        APPDELEGATE.loadMenu()
    }

    // MARK:- Call Api method
    func Api_GetBookingDetailsApi() {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let item = ["booking_id":self.bookingID]
        let url = kServer + KServerPath + K_BookingDetailsApi
        
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
                let responseDict = (result as AnyObject).value(forKey: "my_booking") as! Dictionary<String, Any>
                bookingObj = BookingDetailsInfoModel.getBookingDetails(responseDict: responseDict)
                self.nameLabel.text = self.bookingObj.driver_name
                self.fairLabel.text = bookingObj.price + " GH₵"
                if bookingObj.status == "Cancel"{
                    self.paymentTypeLabel.text = bookingObj.payment_method
                    self.okButtonHeightCons.constant = 0
                }else{
                    if bookingObj.payment_status == "Unpaid"{
                        self.paymentTypeLabel.text = bookingObj.payment_method
                        self.okButtonHeightCons.constant = 56
                        okButton.setTitle("Pay : \(fairLabel.text ?? " GH₵")", for: UIControlState())
                    }else{
                        self.paymentTypeLabel.text = bookingObj.payment_method
                        self.okButtonHeightCons.constant = 0
                    }
                }
               
                self.profileImageView.sd_setImage(with: URL.init(string: bookingObj.driver_img), placeholderImage: UIImage.init(named: "download"))
                self.rideDetailsTableView.reloadData()
            }else{
                let messag = Parser.shared.getStringFrom(data: result, key: "message")
                PDAlert.shared.showAlertWith("Alert!", message: messag, onVC: self)
            }
        }
    }

}

extension RideDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RidseDetailsTableViewCell") as! RidseDetailsTableViewCell
        
        cell.startLocationLabel.text = self.bookingObj.from_address
        cell.destinationLocationLabel.text = self.bookingObj.to_address
        cell.distanceLabel.text = self.bookingObj.ride_distance + " km"
        cell.timeLabel.text = self.bookingObj.drop_date != "" ? self.bookingObj.drop_date + " " + bookingObj.drop_time : "_ _ _"
        cell.tripFairLabel.text = self.bookingObj.price + " GH₵"
        cell.statusLabel.text = self.bookingObj.status
        cell.statusLabel.textColor = self.bookingObj.status == "Cancel" ? RGBA(r: 240, g: 44, b: 46, a: 1) : RGBA(r: 0, g: 152, b: 1, a: 1)
        cell.trafficChargeLabel.text = self.bookingObj.trafficCharge + " GH₵"
        cell.trafficDurationLabel.text = self.bookingObj.trafficDuration + " minutes"
        cell.waitingTimeLabel.text = self.bookingObj.waitingFees + " GH₵"
        cell.cancellationLabel.text = self.bookingObj.cancellationFees + " GH₵"
        if self.bookingObj.waitingFees == "" || self.bookingObj.waitingFees == "0" || self.bookingObj.waitingFees == "0.0" {
           cell.waitingTimeLabel.text = ""
            cell.waitingView.isHidden = true
            cell.waitingLabel.text = ""
        }else{
            cell.waitingView.isHidden = false
            cell.waitingLabel.text = "Waiting charges"

        }
           
           
        if self.bookingObj.cancellationFees == "" || self.bookingObj.cancellationFees == "0" || self.bookingObj.cancellationFees == "0.0"  {
            cell.cancellationLabel.text = ""
            cell.cancelLabel.text = ""
            cell.cancelView.isHidden = true
        }
        else{
            
            cell.cancelLabel.text = "Previous  Cancellation Charges"
            cell.cancelView.isHidden = false
        }
        
        return cell
    }
   
}

extension RideDetailsViewController : PaymentPopUpDelegate {
    
    func dismissPaymentPopUp(isStatus: Bool, isBookingSuccess: Bool, bookingPayId: String) {
        if isBookingSuccess {
            if bookingPayId != "" {
                //                if timer == nil {
                //                    self.count = 20
                //                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                //                    _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
                //                    self.hudView.isHidden = false
                //
                //                }
                
                if Connectivity.isConnectedToInternet {
                    self.gotoHomePage()

                    //                    self.API_Calling_For_CheckBookingStatus(bookingId: bookingId)
                }else {
                    PDAlert.shared.showAlertWith("Alert!", message: "No internet! Please check your internet connection.", onVC: self)
                }
            }
            
        }else {
            
            let addMoneyVC = self.storyboard?.instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
            addMoneyVC.isWallet = isStatus
            addMoneyVC.delegate = self
            addMoneyVC.isFromBookRideVC = true
            self.navigationController?.pushViewController(addMoneyVC, animated: true)
        }
        
    }
}

extension RideDetailsViewController : AddMoneyDelegate {
    
    func showPaymentCustomPopUp(isWallet : Bool)  {
//        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentCustomPopUpViewController") as!  PaymentCustomPopUpViewController
//        popUpVC.delegate = self
//        popUpVC.bookingID = bookingObj.booking_id
//        popUpVC.price = bookingObj.price
//        popUpVC.isWallet = isWallet
//        popUpVC.modalTransitionStyle = .crossDissolve
//        popUpVC.modalPresentationStyle = .overCurrentContext
//        present(popUpVC, animated: false, completion: nil)
    }
}

