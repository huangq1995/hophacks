//
//  friendCell.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/17/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit

class friendCell: UITableViewCell {
    @IBOutlet weak var profpic: UIImageView!

    @IBOutlet weak var usrname: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
