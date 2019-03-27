//
//  BookingRideDetailsViewController.swift
//  Driva
//
//  Created by Manoj Singh on 03/10/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import GoogleMaps
import ASProgressHud
import Alamofire

class BookingRideDetailsViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var bgViewWhereTogo: UIView!
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var destinationLocationButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var rideDetailsView: UIView!
//    @IBOutlet weak var photoView: UIView!
   @IBOutlet weak var modelCar: UILabel!
    @IBOutlet weak var cashPaidLabel: UILabel!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var cancelRideButton: UIButton!
    
    var startMarker = GMSMarker()
    var destinationMarker = GMSMarker()
    var currentMarker = GMSMarker()
     var driverMarker = GMSMarker()
     var apiCounting = 0
    var startLocationStr = ""
    var destinationLocationStr = ""
    
    var startCordinates = CLLocationCoordinate2D()
    var destinationCordinates = CLLocationCoordinate2D()
    var driverCordinates = CLLocationCoordinate2D()

    var price = ""
   
    var points = ""
    var bookingId = ""
    var phoneNumber = ""
    var isRiding = Bool()
    var isRunning = Bool()
    var bookingInfoObj = BookingDetailsInfoModel()
    var locationManager = CLLocationManager()

    var timer : Timer? = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
    }
    
    @IBAction func callButtonAction(_ sender: UIButton) {
        
        let mobileNumberArray = self.phoneNumber.split(separator: "-")
        let countryCode = mobileNumberArray.first!
        let number = mobileNumberArray.last!
        let mobileNo = "\(countryCode)" + "\(number)"
        
        if let url = URL(string: "tel://\(mobileNo)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func cancelRideButtonAction(_ sender: UIButton) {
        let cancelRideVC = self.storyboard?.instantiateViewController(withIdentifier:"CancelRideViewController") as! CancelRideViewController
        cancelRideVC.bookingID = self.bookingId
        cancelRideVC.modalTransitionStyle = .crossDissolve
        cancelRideVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(cancelRideVC, animated: false, completion: nil)
    }
    
    // MARK:- Helper Method
    func initialMethod() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishRideNoficationMethod(notification:)), name: Notification.Name("finishNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startRideNoficationMethod(notification:)), name: Notification.Name("startNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.cancelRequestNoficationMethod(notification:)), name: Notification.Name("cancelNotification"), object: nil)

        self.bgViewWhereTogo.aroundShadow()
        self.rideDetailsView.aroundShadow()

        self.cashPaidLabel.text = "Estimated fare to paid : \(self.price) GH₵"
        
        self.navigationItem.leftBarButtonItem = AppUtility.leftBarButton("", controller: self)
        self.navigationItem.title = isRunning ? "Now you are in ride." : "Your ride is arriving"
        self.startLocationButton.setTitle(startLocationStr, for: .normal)
        self.destinationLocationButton.setTitle(destinationLocationStr, for: .normal)

        if isRunning {
                   // self.mapView.clear()
            
                    self.startMarker = GMSMarker(position: startCordinates)
                    self.startMarker.map = self.mapView
                    self.startMarker.icon = GMSMarker.markerImage(with: .green)
            
                    self.currentMarker = GMSMarker(position: startCordinates)
                    self.currentMarker.map = self.mapView
            
                    self.currentMarker.icon = UIImage.init(named: isRunning ? "car1" : "standing_up_man")
            
                    self.destinationMarker = GMSMarker(position: destinationCordinates)
                    self.destinationMarker.map = self.mapView
            self.fetchMapApiData(startCord: startCordinates, destination: destinationCordinates)
            //initializeTheLocationManager()

        }else{
           
            
            let to_location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((bookingInfoObj.driver_lat as NSString).doubleValue), longitude: Double((bookingInfoObj.driver_lng as NSString).doubleValue))
            driverCordinates = to_location
            
            self.mapView.clear()
            
            self.driverMarker = GMSMarker(position: driverCordinates)
            self.driverMarker.map = self.mapView
            self.driverMarker.icon = UIImage.init(named:  "car1")
            
            
            self.startMarker = GMSMarker(position: startCordinates)
            self.startMarker.map = self.mapView
            self.startMarker.icon = GMSMarker.markerImage(with: .red)
            
            self.fetchMapApiData(startCord: driverCordinates, destination: startCordinates)
            self.scheduledTimerWithTimeInterval()


        }
        if isRiding {
            self.updateData(bookingObj: bookingInfoObj)
        }else {
            if Connectivity.isConnectedToInternet {
                self.Api_GetBookingDetailsApi()
            }else{
                _ = AlertController.alert(K_Opps, message: K_NoInternet)
            }
        }
    }
    
    @IBAction func userImageButtonAction(_ sender: UIButton) {
        self.navigationController?.isNavigationBarHidden = true
        let newImageView = UIImageView(image: self.userImageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(sender:)))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }

    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 10 seconds
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    @objc func updateCounting(){
        if Connectivity.isConnectedToInternet {
           Api_GetDriverLocationApi()
        }else{
          Api_GetDriverLocationApi()
            
        }
    }

    func initializeTheLocationManager() {
        self.mapView.clear()
        
        self.startMarker = GMSMarker(position: startCordinates)
        self.startMarker.map = self.mapView
        self.startMarker.icon = GMSMarker.markerImage(with: .green)
        
      
        
        self.destinationMarker = GMSMarker(position: destinationCordinates)
        self.destinationMarker.map = self.mapView
        self.fetchMapApiData(startCord: startCordinates, destination: destinationCordinates)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locationManager.location?.coordinate
        currentMarker.position = (locationManager.location?.coordinate)!
        currentMarker.rotation = (locationManager.location?.course)!
        
        cameraMoveToLocation(toLocation: location)
//        mapView.settings.myLocationButton = true
        
    }

    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {

        }
    }

    func updateData(bookingObj: BookingDetailsInfoModel) {
        self.bookingInfoObj = bookingObj
        self.otpLabel.text = "OTP : " + bookingObj.otp
        self.carNameLabel.text = bookingObj.taxi_name
        self.userName.text = bookingObj.driver_name
        self.userImageView.sd_setImage(with: URL.init(string: bookingObj.driver_img), placeholderImage: UIImage.init(named: "download"))
        self.carImageView.sd_setImage(with: URL.init(string: bookingObj.car_img), placeholderImage: UIImage.init(named: "demo_car"))
        self.modelCar.text = bookingObj.model
        self.carNumberLabel.text = bookingObj.taxi_no
//        self.carImageView.image = bookingObj.taxi_type_id == "1" ? UIImage.init(named: "11") : bookingObj.taxi_type_id == "2" ? UIImage.init(named: "11") : bookingObj.taxi_type_id == "3" ? UIImage.init(named: "22") : UIImage.init(named: "33")
        self.phoneNumber = bookingObj.driver_mob
    }
    
    @objc func finishRideNoficationMethod(notification: Notification) {
        let booking_id = notification.userInfo!["gcm.notification.booking_id"] as! String
        let rideDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "RideDetailsViewController") as! RideDetailsViewController
        rideDetailsVC.bookingID = booking_id
        rideDetailsVC.isFinish = true
        self.navigationController?.pushViewController(rideDetailsVC, animated: true)
        
    }
    
    @objc func startRideNoficationMethod(notification: Notification) {
        self.navigationItem.title = "Now you are in ride."
        self.mapView.clear()
        self.isRunning = true
        self.currentMarker.icon = UIImage.init(named: "car1")
        self.stopTimer()
        initializeTheLocationManager()
    }
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    @objc func cancelRequestNoficationMethod(notification: Notification) {
        
        let aps = notification.userInfo!["aps"] as! NSDictionary
        let alert = aps["alert"] as! NSDictionary
        let message = alert["body"] as! String
        _ = AlertController.alert("Alert!", message: message, controller: self, buttons: ["OK"], tapBlock: { (UIAlertAction, index) in
            self.gotoHomePage()
        })
        
    }
    
    fileprivate func gotoHomePage()
    {
        APPDELEGATE.loadMenu()
    }

    func fetchMapData(points : String) {
        
        OperationQueue.main.addOperation({
            let path = GMSPath.init(fromEncodedPath: points)
            let polyline = GMSPolyline.init(path: path)
            polyline.strokeWidth = 5
            polyline.strokeColor = .black
            
            let bounds = GMSCoordinateBounds(path: path!)
            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
            polyline.map = self.mapView
        })
    }
    
    // MARK:- Call Api method
    func Api_GetBookingDetailsApi() {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let item = ["booking_id":self.bookingId]
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
    func Api_GetDriverLocationApi() {
        
        apiCounting = apiCounting + 1
        let item = ["driver_id":self.bookingInfoObj.driver_id]
        let url = kServer + KServerPath + K_DriverLocationApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            if let JSON = response{
                self.succeesDataDriverLocation(result: (JSON as? NSDictionary) ?? [:])
            }else{

               // PDAlert.shared.showAlertWith("Alert!", message: K_SomethingWentWrong, onVC: self)
            }
        })
    }
    
    // MARK:- Handle response of Api
    func succeesData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let responseDict = (result as AnyObject).value(forKey: "my_booking") as! Dictionary<String, Any>
                let bookingDetailsObj = BookingDetailsInfoModel.getBookingDetails(responseDict: responseDict)
                self.updateData(bookingObj: bookingDetailsObj)
            }else{
                let messag = Parser.shared.getStringFrom(data: result, key: "message")
                PDAlert.shared.showAlertWith("Alert!", message: messag, onVC: self)
            }
        }
    }
    func succeesDataDriverLocation(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
           
             let lattitude = (result as AnyObject).value(forKey: "driver_lat") as? NSString
             let long = (result as AnyObject).value(forKey: "driver_lng") as? NSString
             
                let to_location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((lattitude)?.doubleValue ?? 0.00), longitude: Double((long)?.doubleValue ?? 0.00))

                driverCordinates = to_location
                
                       self.mapView.clear()
           
                        self.driverMarker = GMSMarker(position: driverCordinates)
                        self.driverMarker.map = self.mapView
                        self.driverMarker.icon = UIImage.init(named:  "car1")
                
                
                        self.startMarker = GMSMarker(position: startCordinates)
                        self.startMarker.map = self.mapView
                        self.startMarker.icon = GMSMarker.markerImage(with: .red)

                self.fetchMapApiData(startCord: driverCordinates, destination: startCordinates)
                

                
             
            }else{
                let messag = Parser.shared.getStringFrom(data: result, key: "message")

               // PDAlert.shared.showAlertWith("Alert!", message: messag, onVC: self)
            }
        }
    }


    func fetchMapApiData(startCord :CLLocationCoordinate2D ,destination destinationCord : CLLocationCoordinate2D ) {
        
        let from_location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: startCord.latitude, longitude: startCord.longitude)
        let to_location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: destinationCord.latitude, longitude: destinationCord.longitude)
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
        "origin=\(from_location.latitude),\(from_location.longitude)&destination=\(to_location.latitude),\(to_location.longitude)&mode=driving&key=\(GoogleApiKey)&sensor=false"
        
        Alamofire.request(directionURL).responseJSON
            { response in
                if let JSON = response.result.value {
                    
                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                    
                    let routesArray = mapResponse["routes"] as! Array<Dictionary<String, AnyObject>>
                    if routesArray.count == 0 {
                        if Connectivity.isConnectedToInternet {
                           // let message = mapResponse["error_message"] as! String
//                            print(message)
                            self.fetchMapApiData(startCord: startCord, destination: destinationCord)
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
                            
                            let pointsData = points as! String
                            
                            self.fetchMapData(points: pointsData)

                            }
                        )
                        return
                    }
                }
        }
    }

}
