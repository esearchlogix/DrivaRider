//
//  ChangePasswordTableViewCell.swift
//  Driva
//
//  Created by Manoj Singh on 29/09/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit

class ChangePasswordTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var inputTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
