//
//  WalletHistoryViewController.swift
//  Driva
//
//  Created by Manoj Singh on 01/10/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud

class WalletHistoryViewController: UIViewController {

    @IBOutlet weak var walletHistoryTableView: UITableView!
    
    var walletInfoArray = [WalletInfo]()
    
    // MARK:- ViewController Life-Cycle
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
        self.navigationController?.popViewController(animated: true)
    }

    // MARK:- Helper Method
    func initialMethod() {
        if Connectivity.isConnectedToInternet {
            self.API_Calling_For_GetWalletHistory()
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }
        let leftTitle = UILabel.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        leftTitle.text = "Transaction History"
        self.navigationItem.leftBarButtonItems = [AppUtility.leftBarButton("back", controller: self), UIBarButtonItem.init(customView: leftTitle)]
    }
    
    // MARK:- Call Api method
    func API_Calling_For_GetWalletHistory() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["user_id":userId]
        let url = kServer + KServerPath + K_GetCashWalletHistoryApi
        
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
                let wallet_history = (result as AnyObject).value(forKey: "wallet_history") as? Array<Dictionary<String, Any>>
                self.walletInfoArray = WalletInfo.getWalletHistoryDetails(responseArray: wallet_history!)
                self.walletHistoryTableView.reloadData()
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }

}

extension WalletHistoryViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletHistoryTableViewCell") as! WalletHistoryTableViewCell
        let walletObj = walletInfoArray[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showDate = dateFormatter.date(from: walletObj.added_date)
        dateFormatter.dateFormat = "dd-MMM-yy"
        let dateString = dateFormatter.string(from: showDate!)
        
        cell.dateLabel.text = dateString
        cell.statusLabel.text = walletObj.status
        cell.transactionIdLabel.text = walletObj.transaction_id
        cell.creditLabel.text = walletObj.balance_in
        cell.debitLabel.text = walletObj.balance_out

        return cell
    }
    
}
