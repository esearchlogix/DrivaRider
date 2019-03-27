//
//  MenuViewController.swift
//  Driva
//
//  Created by mediatrenz on 23/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift


enum Menu: Int {
    case BookYourRide = 0
    case YourRides
    case Payemnt
}


protocol MenuProtocol : class {
    func changeOndidSelectRowAt(_ menu: Menu)
}
class MenuViewController: UIViewController,MenuProtocol {
   var itemsArry = Array<AnyObject>()
    
    var BookYourRideVC: UIViewController!
    var YourRidesVC: UIViewController!
    var WalletVC: UIViewController!
    var priviuscell: Int = 0
    
    
    @IBOutlet weak var MainTableView: UITableView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemsArry = ["Book Your Ride","Your Rides","Credit Wallet"] as [AnyObject]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookRide = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.BookYourRideVC = UINavigationController(rootViewController: bookRide)
        let YourRides = storyboard.instantiateViewController(withIdentifier: "YourRidesViewController") as! YourRidesViewController
        self.YourRidesVC = UINavigationController(rootViewController: YourRides)
        let walletVC = storyboard.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
        self.WalletVC = UINavigationController(rootViewController: walletVC)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userInfo = UserDetail.shared.getUserInfo()
        let userName = userInfo.value(forKey: UserKeys.user_fullname.rawValue) as! String
        let userImage = UserDetail.shared.getUserImage()
        self.userNameLabel.text = userName
        self.userProfileImageView.sd_setImage(with: URL.init(string: userImage), placeholderImage: #imageLiteral(resourceName: "download"))

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let Profile = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.BookYourRideVC = UINavigationController(rootViewController: Profile)
        
        let Account = storyboard.instantiateViewController(withIdentifier: "YourRidesViewController") as! YourRidesViewController
        self.YourRidesVC = UINavigationController(rootViewController: Account)
        
        let walletVC = storyboard.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
        self.WalletVC = UINavigationController(rootViewController: walletVC)
        MainTableView.separatorStyle = .none
        self.MainTableView.reloadData()
    }

    @IBAction func GoToProfilePage(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let InspectionList = storyboard.instantiateViewController(withIdentifier: "profileViewController") as! profileViewController
        self.BookYourRideVC = UINavigationController(rootViewController: InspectionList)
        self.slideMenuController()?.changeMainViewController(self.BookYourRideVC, close: true)
        
    }
    
    //MARK: Delegate Method - on didSelectRowAt
    func changeOndidSelectRowAt(_ menu: Menu) {
        switch menu {
        case .BookYourRide:
            self.slideMenuController()?.changeMainViewController(self.BookYourRideVC, close: true)
        case .YourRides:
            self.slideMenuController()?.changeMainViewController(self.YourRidesVC, close: true)
        case .Payemnt:
            self.slideMenuController()?.changeMainViewController(self.WalletVC, close: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension MenuViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuTableViewCell
        cell.selectionStyle = .none
        cell.TitelLib.text! = itemsArry[indexPath.row] as! String
         cell.imageIcon.image = UIImage(named: String(format: "%d", indexPath.row))
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    _ = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        let indexP = IndexPath(item: priviuscell, section: 0)
        tableView.reloadRows(at: [indexP], with: .top)
        priviuscell = indexPath.row
        if let menu = Menu(rawValue: indexPath.row) {
            self.changeOndidSelectRowAt(menu)
            
        }
    }

}

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var TitelLib: UILabel!
}
