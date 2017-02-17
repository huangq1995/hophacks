//
//  postCell.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/15/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit
import Parse

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
    
    @IBAction func upvote_click(_ sender: AnyObject) {
        // declare title of button
        let title = sender.title(for: UIControlState())
        
        // to like //assume we have a class for like/dislike storage
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = uuid.text
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("liked")
                    self.likebtn.setTitle("like", for: UIControlState())
                    self.likebtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState()) //assume we have a icon for upvoted/liked state
                    
                    // send notification if we liked to refresh TableView
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                    
                    // send notification as like just wrote this part in case we want to send notifications - maybe we just need to send a number
                    if self.usrname.titleLabel?.text != PFUser.current()?.username {
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.current()?.username
                        newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        newsObj["to"] = self.usrname.titleLabel!.text
                        newsObj["owner"] = self.usrname.titleLabel!.text
                        newsObj["uuid"] = self.uuid.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                    
                }
            })
            
            // to dislike
        } else {
            
            // request existing likes of current user to show post
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: uuid.text!)
            query.findObjectsInBackground { (objects, error) -> Void in
                
                // find objects - likes
                for object in objects! {
                    
                    // delete found like(s)
                    object.deleteInBackground(block: { (success, error) -> Void in
                        if success {
                            print("disliked")
                            self.likebtn.setTitle("unlike", for: UIControlState())
                            self.likebtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState())
                            
                            // send notification if we liked to refresh TableView
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                            
                            
                            // delete like notification - also just wrote it in case
                            let newsQuery = PFQuery(className: "news")
                            newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                            newsQuery.whereKey("to", equalTo: self.usrname.titleLabel!.text!)
                            newsQuery.whereKey("uuid", equalTo: self.uuid.text!)
                            newsQuery.whereKey("type", equalTo: "like")
                            newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                }
                            })
                            
                            
                        }
                    })
                }
            }
            
        }

    }
    
    @IBAction func downvote_clicked(_ sender: AnyObject) {
        //similar stuff
        let title2 = sender.title(for: UIControlState())
        
        // to like //assume we have a class for like/dislike storage
        if title2 == "nodown" {
            
            let object = PFObject(className: "downvote")
            object["by"] = PFUser.current()?.username
            object["to"] = uuid.text
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("downed")
                    self.likebtn.setTitle("downvoted", for: UIControlState())
                    self.likebtn.setBackgroundImage(UIImage(named: "down.png"), for: UIControlState()) //assume we have a icon for upvoted/liked state
                    
                    // send notification if we liked to refresh TableView
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "downed"), object: nil)
                }
            })
        } else {
            
            // request existing likes of current user to show post
            let query = PFQuery(className: "downvote")
            query.whereKey("by", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: uuid.text!)
            query.findObjectsInBackground { (objects, error) -> Void in
                
                // find objects - likes
                for object in objects! {
                    
                    // delete found like(s)
                    object.deleteInBackground(block: { (success, error) -> Void in
                        if success {
                            print("disliked")
                            self.dislike.setTitle("nodown", for: UIControlState())
                            self.dislike.setBackgroundImage(UIImage(named: "nodown.png"), for: UIControlState())
                            
                            // send notification if we liked to refresh TableView
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "downed"), object: nil)
                        }
                    })
                }
            }
            
            

        }
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
