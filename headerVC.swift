//
//  headerVC.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/14/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit
import Parse

class headerVC: UICollectionReusableView {
        
    @IBOutlet weak var pickTitle: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var usrname: UILabel!
    @IBOutlet weak var prof: UIImageView!
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var pick: UILabel!
    @IBOutlet weak var descrip: UILabel!
    @IBOutlet weak var editprof: UIButton!
    // clicked follow button from GuestVC
    /*
    @IBAction func followBtn_clicked(_ sender: AnyObject) {
        
        let title = button.title(for: UIControlState()) //friend button
        
        // be friend
        if title == "befriended" {
            let object = PFObject(className: "follow")
            object["from"] = PFUser.current()?.username
            object["to"] = guestname.last!
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.button.setTitle("friended", for: UIControlState())
                    self.button.backgroundColor = .green
                    
                    // send follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                    newsObj["to"] = guestname.last
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                    
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
            // unfollow
        } else {
            let query = PFQuery(className: "friend")
            query.whereKey("from", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: guestname.last!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                self.button.setTitle("befriended", for: UIControlState())
                                self.button.backgroundColor = .lightGray
                                
                                
                                // delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: guestname.last!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                                
                            } else {
                                print(error?.localizedDescription ?? String())
                            }
                        })
                    }
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
        }
        
    }
 */

}
