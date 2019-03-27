//
//  BookingInfo.swift
//  Driva
//
//  Created by Manoj Singh on 10/10/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit

class BookingInfo: NSObject {
    
    var booking_date_time = ""
    var booking_id = ""
    var driver_id = ""
    var driver_img = ""
    var driver_mob = ""
    var driver_name = ""
    var from_address = ""
    var payment_method = ""
    var price = ""
    var status = ""
    var taxi_type_id = ""
    var taxi_type_name = ""
    var to_address = ""

    class func getBookingHistoryDetails(responseArray : Array<Dictionary<String, Any>>) -> [BookingInfo] {
        var bookingInfoObjArray = [BookingInfo]()
        for dict in responseArray {
            let bookingInfoObj = BookingInfo()
            
            bookingInfoObj.booking_date_time = Parser.shared.getStringFrom(data: dict as AnyObject, key: "booking_date_time")
            bookingInfoObj.booking_id = Parser.shared.getStringFrom(data: dict as AnyObject, key: "booking_id")
            bookingInfoObj.driver_id = Parser.shared.getStringFrom(data: dict as AnyObject, key: "driver_id")
            bookingInfoObj.driver_img = Parser.shared.getStringFrom(data: dict as AnyObject, key: "driver_img")
            bookingInfoObj.driver_mob = Parser.shared.getStringFrom(data: dict as AnyObject, key: "driver_mob")
            bookingInfoObj.driver_name = Parser.shared.getStringFrom(data: dict as AnyObject, key: "driver_name")
            bookingInfoObj.from_address = Parser.shared.getStringFrom(data: dict as AnyObject, key: "from_address")
            if Parser.shared.getStringFrom(data: dict as AnyObject, key: "payment_status") == "Unpaid" {
            bookingInfoObj.payment_method = "Unpaid"
            }else{
                  bookingInfoObj.payment_method = Parser.shared.getStringFrom(data: dict as AnyObject, key: "payment_method")
            }
            bookingInfoObj.price = Parser.shared.getStringFrom(data: dict as AnyObject, key: "price")
            bookingInfoObj.status = Parser.shared.getStringFrom(data: dict as AnyObject, key: "status")
            bookingInfoObj.taxi_type_id = Parser.shared.getStringFrom(data: dict as AnyObject, key: "taxi_type_id")
            bookingInfoObj.taxi_type_name = Parser.shared.getStringFrom(data: dict as AnyObject, key: "taxi_type_name")
            bookingInfoObj.to_address = Parser.shared.getStringFrom(data: dict as AnyObject, key: "to_address")

            bookingInfoObjArray.append(bookingInfoObj)
        }
        
        return bookingInfoObjArray
    }
}
