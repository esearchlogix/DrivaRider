//
//  StaticPageViewController.swift
//  Layu
//
//  Created by Manoj SIngh on 18/09/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import ASProgressHud

protocol ShowPaymentPopUpDelegate {
    func showPopUp()
}

class StaticPageViewController: UIViewController {

    var delegate: ShowPaymentPopUpDelegate?
    
    @IBOutlet weak var staticWebView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var index = -1
    var openUrlStr = ""
    var isFromBookingRide = Bool()
    var checkoutID = ""
    var isHubtle = Bool()

    // MARK:- ViewController Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialMethod()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- IBAction Method
    @objc func leftBarButtonAction(_ button : UIButton) {
        if index == 2 {
            if isFromBookingRide {
                if (self.delegate != nil) {
                    self.delegate?.showPopUp()
                }
            }else {
                if isHubtle == true{
                    if Connectivity.isConnectedToInternet {
                        self.API_Calling_For_CheckPaymentStatus()
                    }else{
                        _ = AlertController.alert("Alert!", message: K_NoInternet)
                    }
                }else{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller is WalletViewController {
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            }
            }
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK:- Call Api method
    func API_Calling_For_CheckPaymentStatus() -> Void {
        
        _ = ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userId = userInfo.value(forKey: UserKeys.user_id.rawValue) as! String
        
     
        let item = ["user_id":userId, "checkoutid":checkoutID]
        let url = kServer + KServerPath + K_HubtelPaymentCheckApi
        
        APIHelper.shared.callAPIPost(item, sUrl: url, completion: { (response) in
            _ = ASProgressHud.hideAllHUDsForView(self.view, animated: true)
            if let JSON = response{
                self.succeesData(result: (JSON as? NSDictionary) ?? [:])
            }else{
                _ = AlertController.alert("Alert!", message: K_SomethingWentWrong)
                
            }
        })
        
    }
    // MARK:- API response

    func succeesData(result : NSDictionary) {
   
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller is WalletViewController {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        let message = (result as AnyObject).value(forKey: "message") as? String
        _ = AlertController.alert("Alert!", message: message!)
    }
    
    // MARK:- Helper Method
    func initialMethod() {
        
        let leftTitle = UILabel.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        leftTitle.text = "Back"

        self.navigationItem.leftBarButtonItems = [AppUtility.leftBarButton("back", controller: self), UIBarButtonItem.init(customView: leftTitle)]
        self.navigationItem.title = index == 0 ? "Terms and Conditions" : index == 1 ? "Privacy Policy" : ""
        if Connectivity.isConnectedToInternet {
            self.loadWebView(urlStr: index == 0 ? K_TermsConditionsApi : index == 1 ? K_PrivacyPolicyApi : openUrlStr )
        }else{
            _ = AlertController.alert("Alert!", message: K_NoInternet)
        }
    }
    
    // Load Webview
    func loadWebView(urlStr : String) {
        if index == 2 {
            guard let url = URL(string: urlStr) else {
                return
            }
            let requestObj = URLRequest(url: url)
            DispatchQueue.main.async {
                self.staticWebView.loadRequest(requestObj)
            }
        }else {
            let url = URL (string: kServer + KServerPath + urlStr)
            let requestObj = URLRequest(url: url!)
            DispatchQueue.main.async {
                self.staticWebView.loadRequest(requestObj)
            }
        }
    }
}

extension StaticPageViewController : UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView){
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        activityIndicator.stopAnimating()
    }

}
