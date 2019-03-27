//
//  WalletInfo.swift
//  Driva
//
//  Created by Manoj Singh on 01/10/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit

class WalletInfo: NSObject {

    var added_date = ""
    var balance_in = ""
    var balance_out = ""
    var id = ""
    var status = ""
    var transaction_id = ""

    class func getWalletHistoryDetails(responseArray : Array<Dictionary<String, Any>>) -> [WalletInfo] {
        var walletInfoObjArray = [WalletInfo]()
        for dict in responseArray {
            let walletInfoObj = WalletInfo()
            
            walletInfoObj.added_date = Parser.shared.getStringFrom(data: dict as AnyObject, key: "added_date")
            walletInfoObj.balance_in = Parser.shared.getStringFrom(data: dict as AnyObject, key: "balance_in")
            walletInfoObj.balance_out = Parser.shared.getStringFrom(data: dict as AnyObject, key: "balance_out")
            walletInfoObj.id = Parser.shared.getStringFrom(data: dict as AnyObject, key: "id")
            walletInfoObj.status = Parser.shared.getStringFrom(data: dict as AnyObject, key: "status")
            walletInfoObj.transaction_id = Parser.shared.getStringFrom(data: dict as AnyObject, key: "transaction_id")
            
            walletInfoObjArray.append(walletInfoObj)
        }
        
        return walletInfoObjArray
    }
}
