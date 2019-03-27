//
//  YourRideTableViewCell.swift
//  Driva
//
//  Created by Manoj Singh on 10/10/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit

class YourRideTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var destinationLocationLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var paymentTypeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.aroundShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
