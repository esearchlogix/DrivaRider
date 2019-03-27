//
//  PreetiAlert.swift
//  truckConvc
//
//  Created by mediatrenz on 04/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import Foundation
import UIKit


class PDAlert: NSObject {
   
    private override init() { }
    
  
    static let shared = PDAlert()
    
    typealias CompletionAlertAction = () -> Void
    
    func showAlertWith(_ title:String!, message:String!, onVC:UIViewController!) -> Void {
        let alertC = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertC.addAction(okAction)
        onVC.present(alertC, animated: true, completion: nil)
    }
    
    func showAlerForActionWithNo(title:String,msg:String, yes:String!, no:String, onVC:UIViewController!, Completion:@escaping CompletionAlertAction) -> Void {
        let alertC = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        let yesAction = UIAlertAction.init(title: yes, style: .default) { (alert) in
            Completion()
        }
        let noAction = UIAlertAction.init(title: no, style: .cancel, handler: nil)
        alertC.addAction(yesAction)
        alertC.addAction(noAction)
        onVC.present(alertC, animated: true, completion: nil)
    }
    func showAlerForActionWith(title:String,msg:String, yes:String!, onVC:UIViewController!, Completion:@escaping CompletionAlertAction) -> Void {
        let alertC = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        let yesAction = UIAlertAction.init(title: yes, style: .default) { (alert) in
            Completion()
        }
        alertC.addAction(yesAction)
        onVC.present(alertC, animated: true, completion: nil)
    }
    
}
