//
//  RidseDetailsTableViewCell.swift
//  Driva
//
//  Created by Manoj Singh on 20/11/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit

class RidseDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var destinationLocationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tripFairLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var waitingTimeLabel: UILabel!
    @IBOutlet weak var cancellationLabel: UILabel!
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var trafficDurationLabel: UILabel!
    @IBOutlet weak var trafficChargeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.detailView.aroundShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
