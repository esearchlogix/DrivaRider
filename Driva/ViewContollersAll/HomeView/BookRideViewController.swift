//
//  BookRideViewController.swift
//  Driva
//
//  Created by Manoj Singh on 27/09/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import ASProgressHud
import GooglePlaces
import Alamofire

class BookRideViewController: UIViewController {

    @IBOutlet weak var bgViewWhereTogo: UIView!
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var destinationLocationButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var priceLabel: UILabel!
     @IBOutlet weak var penaltyLabel: UILabel!
    @IBOutlet weak var hudView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    var startMarker = GMSMarker()
    var destinationMarker = GMSMarker()

    var startLocationStr = ""
    var destinationLocationStr = ""

    var taxiID = ""
    var startCordinates = CLLocationCoordinate2D()
    var destinationCordinates = CLLocationCoordinate2D()
    var distance = ""
    var time = ""
    var price = ""
    var points = ""
    var penaltyStatus : String? = ""
    var apiCallCount = Int()
    var count = 20
    var timer: Timer?
    var bookingID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        initialMethod()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
        self.navigationController?.popViewController(animated: true)

//        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomPopUpViewController") as!  CustomPopUpViewController
//        popUpVC.delegate = self
//        popUpVC.modalTransitionStyle = .crossDissolve
//        popUpVC.modalPresentationStyle = .overCurrentContext
//        present(popUpVC, animated: false, completion: nil)
    }

    @IBAction func cancelButtonAction(_ sender: UIButton) {
        _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
        self.navigationController?.popViewController(animated: true)

//        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomPopUpViewController") as!  CustomPopUpViewController
//        popUpVC.delegate = self
//        popUpVC.modalTransitionStyle = .crossDissolve
//        popUpVC.modalPresentationStyle = .overCurrentContext
//        present(popUpVC, animated: false, completion: nil)
    }
    
    @IBAction func bookRideButtonAction(_ sender: UIButton) {
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentCustomPopUpViewController") as!  PaymentCustomPopUpViewController
        popUpVC.delegate = self
        popUpVC.taxiID = self.taxiID
        popUpVC.startCordinates = self.startCordinates
        popUpVC.destinationCordinates = self.destinationCordinates
        popUpVC.distance = self.distance
        popUpVC.time = self.time
        popUpVC.price = self.price
        popUpVC.comingFrom = "Book Ride"
        popUpVC.from_address = self.startLocationStr
        popUpVC.to_address = self.destinationLocationStr
        popUpVC.modalTransitionStyle = .crossDissolve
        popUpVC.penaltystatus = penaltyStatus ?? ""
        popUpVC.modalPresentationStyle = .overCurrentContext
        present(popUpVC, animated: false, completion: nil)
//        if Connectivity.isConnectedToInternet {
//            self.API_Calling_For_BookRide()
//        }else{
//            _ = AlertController.alert("Alert!", message: K_NoInternet)
//        }
    }

    

    
    // MARK:- Helper Method
    func initialMethod() {

        let leftButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        leftButton.setImage(#imageLiteral(resourceName: "log"), for: .normal)
        leftButton.contentMode = .scaleAspectFill
        leftButton.isUserInteractionEnabled = false
        
        self.apiCallCount = 0

        self.navigationItem.leftBarButtonItems = [AppUtility.leftBarButton("back", controller: self), UIBarButtonItem.init(customView: leftButton)]
        self.bgViewWhereTogo.aroundShadow()
        self.hudView.aroundShadow()
        self.hudView.isHidden = true
        self.startLocationButton.setTitle(startLocationStr, for: .normal)
        self.destinationLocationButton.setTitle(destinationLocationStr, for: .normal)
        
        self.mapView.clear()
        self.startMarker = GMSMarker(position: startCordinates)
        self.startMarker.map = self.mapView
        self.startMarker.icon = GMSMarker.markerImage(with: .green)
        self.destinationMarker = GMSMarker(position: destinationCordinates)
        self.destinationMarker.map = self.mapView
        
        if Connectivity.isConnectedToInternet {
            _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
            fetchMapData()
        }else {
            PDAlert.shared.showAlertWith("Alert!", message: "No internet! Please check your internet connection.", onVC: self)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.acceptRequestNoficationMethod(notification:)), name: Notification.Name("acceptNotification"), object: nil)

    }
    
    @objc func acceptRequestNoficationMethod(notification: Notification) {
        
//        print(notification.userInfo!)
//        self.count = 0
//        update()
      
        self.stopTimer()
      self.Api_GetBookingDetailsApi()
      

    }
    
    fileprivate func gotoHomePage()
    {
        APPDELEGATE.loadMenu()
    }

    func fetchMapData() {
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
            "origin=\(startCordinates.latitude),\(startCordinates.longitude)&destination=\(destinationCordinates.latitude),\(destinationCordinates.longitude)&mode=driving&key=\(GoogleApiKey)&sensor=false"
        
        Alamofire.request(directionURL).responseJSON
            { response in
                if let JSON = response.result.value {
                    
                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                    
                    let routesArray = mapResponse["routes"] as! Array<Dictionary<String, AnyObject>>
                    if routesArray.count == 0 {
                        if Connectivity.isConnectedToInternet {
                            
                            
                            if let message = mapResponse["error_message"] as? String{
                                 self.fetchMapData()
                            }
//                            print(message)
                           
                        }else {
                            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
                            PDAlert.shared.showAlertWith("Alert!", message: "No internet! Please check your internet connection.", onVC: self)
                            return
                        }
                    }else {
                        let route = routesArray.first!
                        
                        OperationQueue.main.addOperation({
                            let routeOverviewPolyline:NSDictionary = (route as NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            
                            self.points = points as! String
                            
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 5
                            polyline.strokeColor = .black
                            
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            polyline.map = self.mapView
                            
                            let legs = route["legs"] as! Array<Dictionary<String, AnyObject>>
                            
                            let firstObj = (legs.first) ?? [:]
                            let distanceDict = (firstObj["distance"] as? Dictionary<String,AnyObject>) ?? [:]
                            let durationDict = (firstObj["duration"] as? Dictionary<String,AnyObject>) ?? [:]
                            self.distance = distanceDict["text"] as! String
                            self.time = durationDict["text"] as! String

                            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
                            if Connectivity.isConnectedToInternet {
                                self.Api_CalculateTaxiFareApi()
                            }else {
                                PDAlert.shared.showAlertWith("Alert!", message: "No internet! Please check your internet connection.", onVC: self)
                            }
                            }
                        )
                        return
                    }
                }
        }
    }
    
    /////API Calling
    func Api_CalculateTaxiFareApi() {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String

        let item = ["user_id":userId,"taxi_id":taxiID,"distance":self.distance,"time":self.time]
        let url = kServer + KServerPath + K_CalculateTaxiFare
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                PDAlert.shared.showAlertWith("Alert!", message: K_SomethingWentWrong, onVC: self)
            }
        })
    }
    
    func succeesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let fare = (result as AnyObject).value(forKey: "calculated_fare") as! Double
                 penaltyStatus = (result as AnyObject).value(forKey: "penalty") as? String
                if let penalty = (result as AnyObject).value(forKey: "penalty_fare")  {
                    if penaltyStatus == "1"{
                    self.penaltyLabel.isHidden = false
                    self.penaltyLabel.text = "Penalty Charges: \(penalty)" + " GH₵"
                    }else{
                        self.penaltyLabel.isHidden = true

                    }

                }else{
                }
                self.price = String(format: "%.2f", fare)
                self.priceLabel.text = "Estimated Fare to Pay: " + String(format: "%.2f", fare) + " GH₵"
            }else{
                let messag = Parser.shared.getStringFrom(data: result, key: "message")
                PDAlert.shared.showAlertWith("Alert!", message: messag, onVC: self)
            }
        }
    }

}

extension BookRideViewController : CustomPopUpDelegate {
    
    func backToViewController() {
        _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension BookRideViewController : PaymentPopUpDelegate   {
    
    func dismissPaymentPopUp(isStatus: Bool, isBookingSuccess: Bool, bookingPayId: String) {
        self.bookingID = bookingPayId
        if isBookingSuccess {
            if bookingID != "" {
                //                if timer == nil {
                //                    self.count = 20
                //                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                //                    _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
                //                    self.hudView.isHidden = false
                //
                //                }
                
                if Connectivity.isConnectedToInternet {
                    self.API_Calling_For_AllotNewDriver(bookingId: bookingID)
                    
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
    // New Allot New Driver
//    func API_Calling_For_CheckBookingStatus(bookingId: String) -> Void {
//
//        self.apiCallCount = self.apiCallCount + 1
//        if self.apiCallCount == 1 {
//            _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
//            self.hudView.isHidden = false
//        }
//
//        let userInfo = UserDetail.shared.getUserInfo()
//        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
//
//        let item = ["booking_id":bookingId, "user_id":userId]
//
//        let url = kServer + KServerPath + K_AllotNewDriverApi
//
//        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
//            if self.apiCallCount == 3 {
//                _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
//                self.hudView.isHidden = true
//            }
//            if let JSON = response{
//                self.checkBookingStatusResponse(result: (JSON as? NSDictionary)!)
//            }else{
//                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
//            }
//        })
//
//    }
    

    func API_Calling_For_AllotNewDriver(bookingId: String) {
        self.apiCallCount = self.apiCallCount + 1
        if self.apiCallCount == 1 {
            _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
            self.hudView.isHidden = false
        }
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["booking_id":bookingId, "user_id":userId]
        
        let url = kServer + KServerPath + K_AllotNewDriverApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            if self.apiCallCount == 4 {
                _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
                self.hudView.isHidden = true
            }
            if let JSON = response{
                self.successSendRequest(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert(K_Opps, message: K_SomethingWentWrong)
            }
        })
    }
    func Api_GetBookingDetailsApi() {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let item = ["booking_id":self.bookingID]
        let url = kServer + KServerPath + K_BookingDetailsApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesDataBookRide(result: (JSON as? NSDictionary) ?? [:])
            }else{
                PDAlert.shared.showAlertWith("Alert!", message: K_SomethingWentWrong, onVC: self)
            }
        })
    }
    func succeesDataBookRide(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let responseDict = (result as AnyObject).value(forKey: "my_booking") as! Dictionary<String, Any>
                let bookingDetailsObj = BookingDetailsInfoModel.getBookingDetails(responseDict: responseDict)
                _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
                self.hudView.isHidden = true
                
                let bookingRideDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "BookingRideDetailsViewController") as! BookingRideDetailsViewController
                bookingRideDetailsVC.startLocationStr = self.startLocationStr
                bookingRideDetailsVC.destinationLocationStr = self.destinationLocationStr
                bookingRideDetailsVC.startCordinates = self.startCordinates
                bookingRideDetailsVC.destinationCordinates = self.destinationCordinates
                bookingRideDetailsVC.price = self.price
                bookingRideDetailsVC.points = self.points
                bookingRideDetailsVC.bookingId = self.bookingID
                bookingRideDetailsVC.bookingInfoObj = bookingDetailsObj
                
                self.navigationController?.pushViewController(bookingRideDetailsVC, animated: true)
            }else{
                let messag = Parser.shared.getStringFrom(data: result, key: "message")
                PDAlert.shared.showAlertWith("Alert!", message: messag, onVC: self)
            }
        }
    }
    
    func successSendRequest(result : NSDictionary) {
        
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "2" {
                self.stopTimer()
                self.Api_GetBookingDetailsApi()
//                _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
//                self.hudView.isHidden = true
//
//                let bookingRideDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "BookingRideDetailsViewController") as! BookingRideDetailsViewController
//                bookingRideDetailsVC.startLocationStr = self.startLocationStr
//                bookingRideDetailsVC.destinationLocationStr = self.destinationLocationStr
//                bookingRideDetailsVC.startCordinates = self.startCordinates
//                bookingRideDetailsVC.destinationCordinates = self.destinationCordinates
//                bookingRideDetailsVC.price = self.price
//                bookingRideDetailsVC.points = self.points
//                bookingRideDetailsVC.bookingId = self.bookingID
//
//                self.navigationController?.pushViewController(bookingRideDetailsVC, animated: true)
            }else{
                if self.apiCallCount < 4 {
                    if timer == nil {
                        self.count = 20
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                    }
                }else {
                    self.apiCallCount = 0
                    self.stopTimer()
                    let message = (result as AnyObject).value(forKey: "message") as? String
                    _ = AlertController.alert("Alert!", message: message!)
                }
            }
        }

//        if let status = (result as AnyObject).value(forKey: "status") as? String {
//            if status == "1" {
//            }else{
//                let message = (result as AnyObject).value(forKey: "message") as? String
//                _ = AlertController.alert("Alert!", message: message!)
//            }
//        }
    }
    
//    func API_Calling_For_CheckBookingStatus(bookingId: String) -> Void {
//
//        self.apiCallCount = self.apiCallCount + 1
//        if self.apiCallCount == 1 {
//            _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
//            self.hudView.isHidden = false
//        }
//
//        let userInfo = UserDetail.shared.getUserInfo()
//        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
//
//        let item = ["booking_id":bookingId, "user_id":userId]
//
//        let url = kServer + KServerPath + K_CheckBookingStatusApi
//
//        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
//            if self.apiCallCount == 3 {
//                _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
//                self.hudView.isHidden = true
//            }
//            if let JSON = response{
//                self.checkBookingStatusResponse(result: (JSON as? NSDictionary)!)
//            }else{
//                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
//            }
//        })
//
//    }
    
//    func checkBookingStatusResponse(result : NSDictionary) {
//        if let status = (result as AnyObject).value(forKey: "status") as? String {
//            if status == "1" {
//                self.stopTimer()
//                _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
//                self.hudView.isHidden = true
//
//                let bookingRideDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "BookingRideDetailsViewController") as! BookingRideDetailsViewController
//                bookingRideDetailsVC.startLocationStr = self.startLocationStr
//                bookingRideDetailsVC.destinationLocationStr = self.destinationLocationStr
//                bookingRideDetailsVC.startCordinates = self.startCordinates
//                bookingRideDetailsVC.destinationCordinates = self.destinationCordinates
//                bookingRideDetailsVC.price = self.price
//                bookingRideDetailsVC.points = self.points
//                bookingRideDetailsVC.bookingId = self.bookingID
//
//                self.navigationController?.pushViewController(bookingRideDetailsVC, animated: true)
//            }else{
//                if self.apiCallCount < 3 {
//                    if timer == nil {
//                        self.count = 20
//                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
//                    }
//                }else {
//                    self.apiCallCount = 0
//                    self.stopTimer()
//                    let message = (result as AnyObject).value(forKey: "message") as? String
//                    _ = AlertController.alert("Alert!", message: message!)
//                }
//            }
//        }
//    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func update() {
        if(self.count > 0) {
            self.count = self.count - 1
//            self.statusLabel.text = "\(self.count)"
        }else {
            stopTimer()
            if Connectivity.isConnectedToInternet {
                self.API_Calling_For_AllotNewDriver(bookingId: self.bookingID)

//                self.API_Calling_For_CheckBookingStatus(bookingId: self.bookingID)
            }else {
                PDAlert.shared.showAlertWith(K_Opps, message: K_NoInternet, onVC: self)
            }
        }
    }
    
}

extension BookRideViewController : AddMoneyDelegate {
    
    func showPaymentCustomPopUp(isWallet : Bool)  {
//        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentCustomPopUpViewController") as!  PaymentCustomPopUpViewController
//        popUpVC.delegate = self
//        popUpVC.taxiID = self.taxiID
//        popUpVC.startCordinates = self.startCordinates
//        popUpVC.destinationCordinates = self.destinationCordinates
//        popUpVC.distance = self.distance
//        popUpVC.time = self.time
//        popUpVC.price = self.price
//        popUpVC.isWallet = isWallet
//        popUpVC.modalTransitionStyle = .crossDissolve
//        popUpVC.modalPresentationStyle = .overCurrentContext
//        present(popUpVC, animated: false, completion: nil)
    }
}
