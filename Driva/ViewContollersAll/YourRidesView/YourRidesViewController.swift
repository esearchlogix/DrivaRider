//
//  YourRidesViewController.swift
//  Driva
//
//  Created by mediatrenz on 10/09/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud

class YourRidesViewController: UIViewController {

    @IBOutlet weak var yourRideTableView: UITableView!
    @IBOutlet weak var noDataFoundLabel: UILabel!
    
    var bookinInfoArray = [BookingInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = AppUtility.leftBarButton("menu", controller: self)
//        self.navigationItem.rightBarButtonItem = AppUtility.rightBarButton("notification", controller: self)
        
        let titleView = UIButton.init(frame: CGRect(x: 10, y: 0, width: 35, height: 40))
        titleView.setImage(#imageLiteral(resourceName: "log"), for: .normal)
        titleView.contentMode = .center
        titleView.isUserInteractionEnabled = false
        self.navigationItem.titleView = titleView
        
        if Connectivity.isConnectedToInternet {
            self.API_Calling_For_GetBookingHistory()
        }else {
            PDAlert.shared.showAlertWith(K_Opps, message: K_NoInternet, onVC: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK:- Call Api method
    func API_Calling_For_GetBookingHistory() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["user_id":userId]
        let url = kServer + KServerPath + K_MyBookingApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
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
                let my_booking = (result as AnyObject).value(forKey: "my_booking") as? Array<Dictionary<String, Any>>
                self.bookinInfoArray = BookingInfo.getBookingHistoryDetails(responseArray: my_booking!)
                self.yourRideTableView.reloadData()
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }

}

extension YourRidesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookinInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourRideTableViewCell") as! YourRideTableViewCell
        
        let bookingObj = bookinInfoArray[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showDate = dateFormatter.date(from: bookingObj.booking_date_time)
        dateFormatter.dateFormat = "dd-MMM-yy h:mm a"
        let dateString = dateFormatter.string(from: showDate!)
        
        cell.dateLabel.text = dateString
        cell.priceLabel.text = bookingObj.price + " GH₵"
        cell.carLabel.text = bookingObj.taxi_type_name
        cell.startLocationLabel.text = bookingObj.from_address
        cell.destinationLocationLabel.text = bookingObj.to_address
        cell.statusLabel.text = bookingObj.status
        cell.paymentTypeLabel.text = bookingObj.payment_method
        cell.paymentTypeLabel.textColor = bookingObj.payment_method == "Unpaid" ? RGBA(r: 240, g: 44, b: 46, a: 1) : RGBA(r: 67, g: 67, b: 67, a: 1)
        cell.statusLabel.textColor = bookingObj.status == "Cancel" ? RGBA(r: 240, g: 44, b: 46, a: 1) : RGBA(r: 0, g: 152, b: 1, a: 1)

        cell.profileImageView.sd_setImage(with: URL.init(string: bookingObj.driver_img), placeholderImage: UIImage.init(named: "download"))

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookingObj = bookinInfoArray[indexPath.row]
        let rideDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "RideDetailsViewController") as! RideDetailsViewController
        rideDetailsVC.bookingID = bookingObj.booking_id
        self.navigationController?.pushViewController(rideDetailsVC, animated: true)
    }
}
