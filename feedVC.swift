//
//  feedVC.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/17/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit
import Parse

class feedVC: UITableViewController {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    // page size
    var page : Int = 10
    // arrays to hold server data
    var usernameArray = [String]()
    var profArray = [PFFile]()
    //var dateArray = [Date?]()
    var picArray = [PFFile]()
    var descripArray = [String]()
    var uuidArray = [String]()
    //display people who we are friends with 
    var friendArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // title at the top
        self.navigationItem.title = "Decide"
        // pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        // receive notification from postsCell if picture is liked, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        // receive notification from postsCell if picture is downvoted, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.refresh), name: NSNotification.Name(rawValue: "downed"), object: nil)
        
        // indicator's x(horizontal) center
        indicator.center.x = tableView.center.x
        
        
        // receive notification from uploadVC
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // refreshign function after like to update degit
    func refresh() {
        tableView.reloadData()
    }
    
    // reloading func with posts  after received notification
    func uploaded(_ notification:Notification) {
        loadPosts()
    }
    //load posts
    func loadPosts() {
        
        // STEP 1. Find posts realted to people who we are friends with
        let followQuery = PFQuery(className: "friend")
        followQuery.whereKey("to", equalTo: PFUser.current()!.username!)
        followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.friendArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.friendArray.append(object.object(forKey: "to") as! String)
                }
                
                // append current user to see own posts in feed
                self.friendArray.append(PFUser.current()!.username!)
                
                // STEP 2. Find posts made by people appended to followArray
                let query = PFQuery(className: "posts")
                query.whereKey("username", containedIn: self.friendArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt") //if we have time
                query.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.profArray.removeAll(keepingCapacity: false)
                        //self.dateArray.removeAll(keepingCapacity: false)
                        self.picArray.removeAll(keepingCapacity: false)
                        self.descripArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        
                        // find related objects
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.profArray.append(object.object(forKey: "profpic") as! PFFile)
                           // self.dateArray.append(object.createdAt) if we have date
                            self.picArray.append(object.object(forKey: "pic") as! PFFile)
                            self.descripArray.append(object.object(forKey: "title") as! String)
                            self.uuidArray.append(object.object(forKey: "uuid") as! String)
                        }
                        
                        // reload tableView & end spinning of refresher
                        self.tableView.reloadData()
                        self.refresher.endRefreshing()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    // clicked username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
        // if user tapped on himself go home, else go guest
        if cell.usrname.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usrname.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
    // scrolled down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! postCell
        
        // connect objects with our information from arrays
        cell.usrname.setTitle(usernameArray[indexPath.row], for: UIControlState())
        cell.usrname.sizeToFit()
        cell.uuid.text = uuidArray[indexPath.row]
        //cell.titleLbl.text = titleArray[indexPath.row]
        //cell.titleLbl.sizeToFit()
        
        // place profile picture
        profArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.prof.image = UIImage(data: data!)
        }
        
        // place post picture
        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        // manipulate like button depending on did user like it or not //here assume we have two graphs for upvoted state and haven't upvoted state
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
        didLike.whereKey("to", equalTo: cell.uuid.text!)
        didLike.countObjectsInBackground { (count, error) -> Void in
            // if no any likes are found, else found likes
            if count == 0 {
                cell.likebtn.setTitle("unlike", for: UIControlState())
                cell.likebtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState())
            } else {
                cell.likebtn.setTitle("like", for: UIControlState())
                cell.likebtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
            }
        }
        
        // count total likes of shown post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuid.text!)
        countLikes.countObjectsInBackground { (count, error) -> Void in
            cell.countlike.text = "\(count)"
        }
        //assume have a new class downvote
        //make a different one for downvote
        let down = PFQuery(className: "downvote")
        down.whereKey("by", equalTo: PFUser.current()!.username!)
        down.whereKey("to", equalTo: cell.uuid.text!)
        down.countObjectsInBackground { (count, error) -> Void in
            // if no any downvote are found, else found downvote
            if count == 0 {
                cell.likebtn.setTitle("nodown", for: UIControlState())
                cell.likebtn.setBackgroundImage(UIImage(named: "nodown.png"), for: UIControlState())
            } else {
                cell.likebtn.setTitle("down", for: UIControlState())
                cell.likebtn.setBackgroundImage(UIImage(named: "down.png"), for: UIControlState())
            }
        }
        
        // count total likes of shown post
        let countLikes2 = PFQuery(className: "downvote")
        countLikes2.whereKey("to", equalTo: cell.uuid.text!)
        countLikes2.countObjectsInBackground { (count, error) -> Void in
            cell.countdislike.text = "\(count)"
        }
        return cell
        
    }

    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // pagination
    func loadMore() {
        
        // if posts on the server are more than shown
        if page <= uuidArray.count {
            
            // start animating indicator
            indicator.startAnimating()
            
            // increase page size to load +10 posts
            page = page + 10
            
            // STEP 1. Find posts realted to people who we are friends with
            let followQuery = PFQuery(className: "friend")
            followQuery.whereKey("to", equalTo: PFUser.current()!.username!)
            followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.friendArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.friendArray.append(object.object(forKey: "to") as! String)
                    }
                    
                    // append current user to see own posts in feed
                    self.friendArray.append(PFUser.current()!.username!)
                    
                    // STEP 2. Find posts made by people appended to followArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.friendArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt") //if we have time
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.profArray.removeAll(keepingCapacity: false)
                            //self.dateArray.removeAll(keepingCapacity: false) if we have time
                            self.picArray.removeAll(keepingCapacity: false)
                            self.descripArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            // find related objects
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.profArray.append(object.object(forKey: "profpic") as! PFFile)
                                //self.dateArray.append(object.createdAt)
                                self.picArray.append(object.object(forKey: "pic") as! PFFile)
                                self.descripArray.append(object.object(forKey: "title") as! String)
                                self.uuidArray.append(object.object(forKey: "uuid") as! String)
                            }
                            
                            // reload tableView & stop animating indicator
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

  */  /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
