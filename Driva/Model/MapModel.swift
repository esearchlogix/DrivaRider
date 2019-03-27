

import UIKit
import CoreLocation

class MapModel: NSObject, CLLocationManagerDelegate {
    // Can't init is singleton
    private override init() { }
    
    // MARK: Shared Instance
    static let shared = MapModel()
    
    var locationManager:CLLocationManager = CLLocationManager()
    
    // MARK: locationUpdateCompletion
    typealias CompletionBlock = (CLLocation?) -> Void
    var locationUpdateCompletion: CompletionBlock = { responseJson in  }
    
    typealias CompletionBlockCenter = (CLLocationCoordinate2D?) -> Void
    var mapCenterCoordinateCompletion: CompletionBlockCenter = { centerCoordinate in  }
    
    var userCordinate:CLLocationCoordinate2D! = CLLocationCoordinate2D.init()
    
    // MARK: Create Marker

    
    // MARK: Location update
    func startUpdatingLocation() -> Void {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last

        userCordinate = location?.coordinate
        
        locationUpdateCompletion(location)
    }
    

}
