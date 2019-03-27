//
//  ViewController.swift
//  Driva
//
//  Created by mediatrenz on 20/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import ASProgressHud
import GooglePlaces
import Alamofire

class ViewController: UIViewController,CLLocationManagerDelegate,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,GMSMapViewDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var carCollectionView: UICollectionView!
    @IBOutlet weak var bgViewWhereTogo: UIView!
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var destinationLocationButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var initialcameraposition:GMSCameraPosition!
    var itemsArry = Array<AnyObject>()
    var carLableArry = Array<AnyObject>()
    var carImageArry = Array<AnyObject>()
    var slectedcarImageArry = Array<AnyObject>()
    var SlectedIndex = 0
    var isFirstTime = Bool()
    var startCordinates = CLLocationCoordinate2D()
    var destinationCordinates = CLLocationCoordinate2D()
    var errorMsg = ""
    var TexiListArr: Array<AnyObject>! = Array<AnyObject>()
    var Dict: NSDictionary! = [:]
    var marker = GMSMarker()
    var isDestinationLocation = Bool()
    var isSearchLocation = Bool()
    var startLocationStr = ""
    var destinationLocationStr = ""
    var isUpdateLocation = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Connectivity.isConnectedToInternet {
            self.API_Calling_For_GetUserBookingStatus()
        }else {
            PDAlert.shared.showAlertWith(K_Opps, message: K_NoInternet, onVC: self)
        }

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

    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if isValidate() {
            
            let bookRideVC = self.storyboard?.instantiateViewController(withIdentifier: "BookRideViewController") as! BookRideViewController
            
            let dict = ((TexiListArr[SlectedIndex] as AnyObject) as! NSDictionary)
            bookRideVC.taxiID = dict["id"] as! String
            bookRideVC.startCordinates = startCordinates
            bookRideVC.destinationCordinates = destinationCordinates
            bookRideVC.startLocationStr = startLocationStr
            bookRideVC.destinationLocationStr = destinationLocationStr

            self.navigationController?.pushViewController(bookRideVC, animated: true)
        }else {
            PDAlert.shared.showAlertWith("Alert!", message: errorMsg, onVC: self)
        }
    }
    
    @IBAction func ChooseStartBtnAction(_ sender: UIButton) {
        isDestinationLocation = false
        isSearchLocation = false

        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func ChooseDestinationBtnAction(_ sender: UIButton) {
        isDestinationLocation = true
        isSearchLocation = false

        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }

}

extension ViewController {
    
    func isValidate() -> Bool {
        let originLocation = "\(startCordinates.latitude),\(startCordinates.longitude)"
        let destinationLocation = "\(destinationCordinates.latitude),\(destinationCordinates.longitude)"

        if originLocation == "0.0,0.0" {
            errorMsg = "Please choose starting point."
            return false
        }else if destinationLocation == "0.0,0.0" {
            errorMsg = "Please choose destination point."
            return false
        }else if destinationLocation == "0.0,0.0" {
            errorMsg = "Please choose destination point."
            return false
        }else {
            return true
        }
    }
    
    func viewDidLordMethord() {

        self.navigationController?.isNavigationBarHidden = false
        
        initializeTheLocationManager()
        self.mapView.isMyLocationEnabled = true
        mapView.isBuildingsEnabled = false
        mapView.isTrafficEnabled = false
        
        self.navigationItem.leftBarButtonItem = AppUtility.leftBarButton("menu", controller: self)
//        self.navigationItem.rightBarButtonItem = AppUtility.rightBarButton("notification", controller: self)
        
        let titleView = UIButton.init(frame: CGRect(x: 10, y: 0, width: 35, height: 40))
        titleView.setImage(#imageLiteral(resourceName: "log"), for: .normal)
        titleView.contentMode = .center
        titleView.isUserInteractionEnabled = false
        self.navigationItem.titleView = titleView
        
        self.bgViewWhereTogo.aroundShadow()

        mapView.delegate = self
        if Connectivity.isConnectedToInternet {
            API_FOR_TexiType()
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }
        carImageArry = ["11","11", "22", "33"] as [AnyObject]
        slectedcarImageArry = ["111", "111", "222", "333"] as [AnyObject]
    }
    
    func initializeTheLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isUpdateLocation {
            isUpdateLocation = true
            let location = locationManager.location?.coordinate
            cameraMoveToLocation(toLocation: location)
            mapView.settings.myLocationButton = true
            
            let current_location = locationManager.location
            if current_location == nil {
                return
            }
            if isDestinationLocation {
                destinationCordinates = (current_location?.coordinate)!
            }else {
                startCordinates = (current_location?.coordinate)!
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: 15)
        }
    }

    //MARK: GMSMapViewDelegate Implimentation.
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
//        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        self.mapView.clear()
        self.marker = GMSMarker(position: coordinate)
        self.marker.map = mapView

        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            if self.isDestinationLocation {
                self.destinationCordinates = coordinate
                self.destinationLocationStr = lines.joined(separator: "\n")
                self.destinationLocationButton.setTitle(lines.joined(separator: "\n"), for: .normal)
            }else {
                self.startCordinates = coordinate
                self.startLocationStr = lines.joined(separator: "\n")
                self.startLocationButton.setTitle(lines.joined(separator: "\n"), for: .normal)
            }
        }
    }
    
    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.TexiListArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carCell", for: indexPath as IndexPath) as! MyCollectionViewCell
        Dict = ((TexiListArr[indexPath.row] as AnyObject) as! NSDictionary)
        cell.carListName.text = Dict["vehicle_name"] as? String
        cell.carLableName.text =  Dict["vehicle_class"] as? String
//        cell.backgroundColor = UIColor.white
        if indexPath.row == SlectedIndex{
            cell.carImage.image = UIImage.init(named: slectedcarImageArry[indexPath.row] as! String)
        }else{
        cell.carImage.image = UIImage.init(named: carImageArry[indexPath.row] as! String)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SlectedIndex = indexPath.row
        self.carCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width/4, height: 83.0)
    }

    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {

        if !isFirstTime {
            cameraMoveToLocation(toLocation: coordinate)
            isFirstTime = true
        }
        self.mapView.clear()
        self.marker = GMSMarker(position: coordinate)
        self.marker.map = mapView

        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            if !self.isSearchLocation {
                if self.isDestinationLocation {
                    self.destinationCordinates = coordinate
                    self.destinationLocationStr = lines.joined(separator: "\n")
                    self.destinationLocationButton.setTitle(lines.joined(separator: "\n"), for: .normal)
                }else {
                    self.startCordinates = coordinate
                    self.startLocationStr = lines.joined(separator: "\n")
                    self.startLocationButton.setTitle(lines.joined(separator: "\n"), for: .normal)
                }
                self.isSearchLocation = false
            }
        }
    }

    // MARK:- Call Api method
    func API_FOR_TexiType() -> Void {
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        let url = HomePageApi().URL_TexiTypeApi
        APIHelper.shared.callAPIGet(url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let Json = response as? Array<AnyObject> {
                self.TexiListArr = Json
        }else{
                PDAlert.shared.showAlertWith("Alert!", message: "Unable to get Texi.", onVC: self)
            }
          self.carCollectionView.reloadData()

        })
    }
    
    func API_Calling_For_GetUserBookingStatus() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["user_id":userId]
        let url = kServer + KServerPath + K_UserBookingStatusApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.successData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
            }
        })
        
    }
    
//    func fetchMapApiData(bookingObj : BookingDetailsInfoModel) {
//
//        let from_location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((bookingObj.from_lat as NSString).doubleValue), longitude: Double((bookingObj.from_lng as NSString).doubleValue))
//        let to_location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((bookingObj.to_lat as NSString).doubleValue), longitude: Double((bookingObj.to_lng as NSString).doubleValue))
//
//        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
//        "origin=\(from_location.latitude),\(from_location.longitude)&destination=\(to_location.latitude),\(to_location.longitude)&mode=driving&key=\(GoogleApiKey)&sensor=false"
//
//        Alamofire.request(directionURL).responseJSON
//            { response in
//                if let JSON = response.result.value {
//
//                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
//
//                    let routesArray = mapResponse["routes"] as! Array<Dictionary<String, AnyObject>>
//                    if routesArray.count == 0 {
//                        if Connectivity.isConnectedToInternet {
//                            let message = mapResponse["error_message"] as! String
//                            print(message)
//                            self.fetchMapApiData(bookingObj: bookingObj)
//                        }else {
//                            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
//                            PDAlert.shared.showAlertWith("Alert!", message: "No internet! Please check your internet connection.", onVC: self)
//                            return
//                        }
//                    }else {
//                        let route = routesArray.first!
//
//                        OperationQueue.main.addOperation({
//                            let routeOverviewPolyline:NSDictionary = (route as NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
//                            let points = routeOverviewPolyline.object(forKey: "points")
//
//
//                            }
//                        )
//                        return
//                    }
//                }
//        }
//    }
//
    // MARK:- Handle response of Api
    func successData(result : NSDictionary) {
        if let status = (result as AnyObject).value(forKey: "status") as? String {
            if status == "1" {
                let responseDict = (result as AnyObject).value(forKey: "my_booking") as! Dictionary<String, Any>
                let bookingObj = BookingDetailsInfoModel.getBookingDetails(responseDict: responseDict)

                if bookingObj.status == "Completed"{
                    let rideDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "RideDetailsViewController") as! RideDetailsViewController
                    rideDetailsVC.bookingID = bookingObj.booking_id
                    rideDetailsVC.isFinish = true
                    self.navigationController?.pushViewController(rideDetailsVC, animated: true)
                }else{
                let bookingRideDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "BookingRideDetailsViewController") as! BookingRideDetailsViewController
                bookingRideDetailsVC.startLocationStr = bookingObj.from_address
                bookingRideDetailsVC.destinationLocationStr = bookingObj.to_address
                let from_location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((bookingObj.from_lat as NSString).doubleValue), longitude: Double((bookingObj.from_lng as NSString).doubleValue))
                let to_location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((bookingObj.to_lat as NSString).doubleValue), longitude: Double((bookingObj.to_lng as NSString).doubleValue))

                bookingRideDetailsVC.startCordinates = from_location
                bookingRideDetailsVC.destinationCordinates = to_location
                bookingRideDetailsVC.price = bookingObj.price
             
//                bookingRideDetailsVC.points = pointsData
                bookingRideDetailsVC.bookingId = bookingObj.booking_id
                bookingRideDetailsVC.isRiding = true
                bookingRideDetailsVC.bookingInfoObj = bookingObj
                if bookingObj.status == "Running" || bookingObj.status == "running"{
                    bookingRideDetailsVC.isRunning = true
                }
                
                self.navigationController?.pushViewController(bookingRideDetailsVC, animated: true)
                }
//
//                self.fetchMapApiData(bookingObj: bookingObj)
                
//                let bookRideVC = self.storyboard?.instantiateViewController(withIdentifier: "BookRideViewController") as! BookRideViewController
//                bookRideVC.bookingInfoObj = bookingObj
//                bookRideVC.isRiding = true
//                self.navigationController?.pushViewController(bookRideVC, animated: true)

            }else if status == "0" {
                viewDidLordMethord()
            }else {
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }

}

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var carListName: UILabel!
    @IBOutlet weak var carLableName: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
        // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
//        print("Place address:", String(describing: place.name) + ", " + String(describing: place.formattedAddress!))
        let locationAddress = String(describing: place.name) + ", " + String(describing: place.formattedAddress!)
        if isDestinationLocation {
            self.destinationLocationStr = locationAddress
            self.destinationLocationButton.setTitle(locationAddress, for: .normal)
        }else {
            self.startLocationStr = locationAddress
            self.startLocationButton.setTitle(locationAddress, for: .normal)
        }

        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(place.coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            self.mapView.clear()
            self.marker = GMSMarker(position: place.coordinate)
            self.marker.map = self.mapView
            self.isSearchLocation = true
            self.cameraMoveToLocation(toLocation: place.coordinate)

            if self.isDestinationLocation {
                self.destinationCordinates = place.coordinate
            }else {
                self.startCordinates = place.coordinate
            }
        }

        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
        // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

