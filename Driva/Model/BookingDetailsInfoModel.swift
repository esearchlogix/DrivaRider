//
//  BookingDetailsInfoModel.swift
//  Driva
//
//  Created by Manoj Singh on 17/10/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit

class BookingDetailsInfoModel: NSObject {
    
    var booking_date_time = ""
    var booking_id = ""
    var driver_id = ""
    var driver_img = ""
    var driver_lat = ""
    var driver_lng = ""
    var driver_mob = ""
    var driver_name = ""
    var drop_date = ""
    var drop_time = ""
    var from_address = ""
    var from_lat = ""
    var from_lng = ""
    var otp = ""
    var payment_method = ""
     var payment_status = ""
    var pickup_date = ""
    var pickup_time = ""
    var price = ""
    
    var ride_distance = ""
    var ride_duration = ""
    var status = ""
    var taxi_name = ""
    var taxi_no = ""
    var taxi_type_id = ""
    var taxi_type_name = ""
    var to_address = ""
    var to_lat = ""
    var to_lng = ""
    var user_id = ""
    var user_img = ""
    var car_img = ""
    var model = ""
    var user_mob = ""
    var user_name = ""
    var waitingFees = ""
    var cancellationFees = ""
    var trafficDuration = ""
    var trafficCharge = ""
    
    class func getBookingDetails(responseDict : Dictionary<String, Any>) -> BookingDetailsInfoModel {
        
        let bookingInfoObj = BookingDetailsInfoModel()
        
        bookingInfoObj.booking_date_time = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "booking_date_time")
        bookingInfoObj.booking_id = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "booking_id")
        bookingInfoObj.driver_id = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "driver_id")
        bookingInfoObj.driver_img = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "driver_img")
        bookingInfoObj.driver_lat = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "driver_lat")
        bookingInfoObj.driver_lng = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "driver_lng")
        bookingInfoObj.driver_mob = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "driver_mob")
        bookingInfoObj.driver_name = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "driver_name")
        bookingInfoObj.drop_date = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "drop_date")
        bookingInfoObj.drop_time = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "drop_time")
        bookingInfoObj.from_address = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "from_address")
        bookingInfoObj.from_lat = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "from_lat")
        bookingInfoObj.from_lng = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "from_lng")
        bookingInfoObj.otp = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "otp")
        if Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "payment_status") == "Unpaid" {
        bookingInfoObj.payment_method = "Unpaid"
               }else{
           bookingInfoObj.payment_method = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "payment_method")
           }
         bookingInfoObj.payment_status = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "payment_status")
        bookingInfoObj.pickup_date = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "pickup_date")
        bookingInfoObj.pickup_time = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "pickup_time")
        bookingInfoObj.price = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "price")
        bookingInfoObj.ride_distance = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "ride_distance")
        bookingInfoObj.ride_duration = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "ride_duration")
        bookingInfoObj.status = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "status")
        bookingInfoObj.taxi_name = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "taxi_name")
        bookingInfoObj.taxi_no = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "taxi_no")
        bookingInfoObj.taxi_type_id = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "taxi_type_id")
        bookingInfoObj.taxi_type_name = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "taxi_type_name")
        bookingInfoObj.to_address = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "to_address")
        bookingInfoObj.to_lat = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "to_lat")
        bookingInfoObj.to_lng = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "to_lng")
        
        bookingInfoObj.user_id = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "user_id")
        bookingInfoObj.user_img = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "user_img")
        bookingInfoObj.car_img = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "vehicle_image")
        bookingInfoObj.model = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "taxi_make_model")

        bookingInfoObj.user_mob = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "user_mob")
        bookingInfoObj.user_name = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "user_name")
        bookingInfoObj.waitingFees = "\((responseDict as AnyObject).value(forKey: "waiting_time_ammount") as? Double ?? 0)"
        bookingInfoObj.cancellationFees = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "cancelation_penalty_ammount")
        bookingInfoObj.trafficCharge = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "traffic_late_price")
        bookingInfoObj.trafficDuration = Parser.shared.getStringFrom(data: responseDict as AnyObject, key: "traffic_late_time")
 
        return bookingInfoObj

    }
    
}
