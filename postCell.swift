//
//  postCell.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/15/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit

class postCell: UITableViewCell {

    
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var countdislike: UILabel!
    @IBOutlet weak var dislike: UIButton!
    @IBOutlet weak var countlike: UILabel!
    @IBOutlet weak var likebtn: UIButton!
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var usrname: UIButton!
    @IBOutlet weak var prof: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // alignment
        let width = UIScreen.main.bounds.width
        
        // allow constraints
        prof.translatesAutoresizingMaskIntoConstraints = false
        usrname.translatesAutoresizingMaskIntoConstraints = false
        //dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        picImg.translatesAutoresizingMaskIntoConstraints = false
        
        likebtn.translatesAutoresizingMaskIntoConstraints = false
        //commentBtn.translatesAutoresizingMaskIntoConstraints = false
        //reBtn.translatesAutoresizingMaskIntoConstraints = false
        dislike.translatesAutoresizingMaskIntoConstraints = false

        countlike.translatesAutoresizingMaskIntoConstraints = false
        //titleLbl.translatesAutoresizingMaskIntoConstraints = false
        uuid.translatesAutoresizingMaskIntoConstraints = false
        
        let pictureWidth = width
        
        // constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[ava(30)]-10-[pic(\(pictureWidth))]-5-[like(30)]",
            options: [], metrics: nil, views: ["ava":prof, "pic":picImg, "like":likebtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[username]",
            options: [], metrics: nil, views: ["username":usrname]))

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
