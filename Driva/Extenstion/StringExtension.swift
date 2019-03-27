//
//  StringExtension.swift
//  Car Inspection
//
//  Created by Preeti dhankar on 21/12/16.
//  Copyright © 2016 Preeti dhankar. All rights reserved.
//

import UIKit

extension String
{
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    var boolValue: Bool {
        return Bool((self as NSString).boolValue)
    }
}


///TextFile Border  Super
extension UITextField {
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}

extension UIView {
    func addViewBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}






//Button Border  Super
extension UIButton {
    func addButtonBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}



///Pedding Of Text file
//extension UITextField {
//    func setLeftPaddingPoints(_ amount:CGFloat){
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//    }
//    func setRightPaddingPoints(_ amount:CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.rightView = paddingView
//        self.rightViewMode = .always
//    }
//}





extension String {
    func getFormateDate(fromFormate:String, toFormate:String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = fromFormate
        if let date = dateFormatter.date(from: self) {
            let toFormatter = DateFormatter.init()
            toFormatter.dateFormat = toFormate
            if let sDate = toFormatter.string(from: date) as? String {
                return sDate
            }
        }
        return ""
    }
    func getDateFromString(formateString:String) -> Date {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = formateString
        let locale = NSTimeZone.init(abbreviation: "BST")
        NSTimeZone.default = locale! as TimeZone
        dateFormatter.timeZone = locale! as TimeZone
        if let dateS = dateFormatter.date(from: self) {
            return dateS
        }
        return Date()
    }
}
