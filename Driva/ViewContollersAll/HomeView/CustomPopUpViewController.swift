//
//  CustomPopUpViewController.swift
//  Driva
//
//  Created by Manoj Singh on 28/09/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit

protocol CustomPopUpDelegate {
    func backToViewController()
}

class CustomPopUpViewController: UIViewController {

    var delegate : CustomPopUpDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- IBAction Method
    @IBAction func noButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesButtonAction(_ sender: UIButton) {
        self.dismiss(animated: false) {
            if (self.delegate != nil) {
                self.delegate?.backToViewController()
            }
        }
    }

}
