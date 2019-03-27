//
//  profileViewController.swift
//  Driva
//
//  Created by mediatrenz on 27/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit

class profileViewController: UIViewController {
    @IBOutlet weak var mainTableView: UITableView!
    var itemsArry = Array<AnyObject>()
    override func viewDidLoad() {
        super.viewDidLoad()


            mainTableView.separatorStyle = .none
        itemsArry = ["My Profile","My Account","Change password","Terms and Conditions","Privacy Policy","Feedback","Log Out"] as [AnyObject]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func MenuAction(_ sender: Any) {
        
        if let slideMenuController = self.slideMenuController() {
            slideMenuController.openLeft()
        }
       }

    }
extension profileViewController: UITableViewDataSource,UITableViewDelegate {

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return itemsArry.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! profileitemsTableview
            cell.selectionStyle = .none
            cell.TitelLib.text! = itemsArry[indexPath.row] as! String
            return cell
            
        }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
        }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
    
            
            
        }
        else if(indexPath.row == 1){
            
        }
        else if(indexPath.row == 2){
            
        }
        else if(indexPath.row == 3){
            
        }
        else if(indexPath.row == 4){
            
        }
        else if(indexPath.row == 5){
            
        }
        else{
           
            
        }
        
        
     }
    
    
    

}


class profileitemsTableview: UITableViewCell {
    @IBOutlet weak var TitelLib: UILabel!
    
}

