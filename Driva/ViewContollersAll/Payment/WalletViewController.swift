//
//  WalletViewController.swift
//  Driva
//
//  Created by Manoj Singh on 29/09/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import ASProgressHud

class WalletViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var walletBalaceLabel: UILabel!
    
    // MARK:- ViewController Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Connectivity.isConnectedToInternet {
            self.API_Calling_For_GetWalletBalance()
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        if let slideMenuController = self.slideMenuController() {
            slideMenuController.openLeft()
        }
    }
    
//    @objc func rightBarButtonAction(_ button : UIButton) {
//    }

    @IBAction func topUpButtonAction(_ sender: UIButton) {
        let addMoneyVC = self.storyboard?.instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
        self.navigationController?.pushViewController(addMoneyVC, animated: true)
    }

    @IBAction func checkHistoryButtonAction(_ sender: UIButton) {
        let walletHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletHistoryViewController") as! WalletHistoryViewController
        self.navigationController?.pushViewController(walletHistoryVC, animated: true)
    }

    // MARK:- Helper Method
    func initialMethod() {
        self.headerView.aroundShadow()
        self.subView.aroundShadow()
        self.navigationItem.leftBarButtonItem = AppUtility.leftBarButton("menu", controller: self)
//        self.navigationItem.rightBarButtonItem = AppUtility.rightBarButton("notification", controller: self)
        
        let titleView = UIButton.init(frame: CGRect(x: 10, y: 0, width: 35, height: 40))
        titleView.setImage(#imageLiteral(resourceName: "log"), for: .normal)
        titleView.contentMode = .center
        titleView.isUserInteractionEnabled = false
        self.navigationItem.titleView = titleView
    }
    
    // MARK:- Call Api method
    func API_Calling_For_GetWalletBalance() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)

        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
        let item = ["user_id":userId]
        let url = kServer + KServerPath + K_GetCashWalletBalanceApi
        
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
                if let balance = (result as AnyObject).value(forKey: "balance") as? String {
                    self.walletBalaceLabel.text = "\(balance) GH₵"
                }else{
                    _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
                }
            }else{
                let message = (result as AnyObject).value(forKey: "message") as? String
                _ = AlertController.alert("Alert!", message: message!)
            }
        }
    }

}
