//
//  guestVC.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/16/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit
import Parse

var guestname = [String]()
private let reuseIdentifier = "Cell"

class guestVC: UICollectionViewController {
    
    // UI objects
    var refresher : UIRefreshControl!
    var page : Int = 12 //might not need it if we are not doing pictures only/collection view
    
    // arrays to hold data from server
    var uuidArray = [String]()
    var picArray = [PFFile]()
    var questArray = [String]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // allow vertical scroll
        self.collectionView!.alwaysBounceVertical = true
        
        // backgroung color
        self.collectionView?.backgroundColor = .white
        
        // top title
        self.navigationItem.title = guestname.last?.uppercased()

        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(guestVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guestVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(guestVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)

        loadPosts()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


        // Do any additional setup after loading the view.
    }
    
    // refresh function
    func refresh() {
        refresher.endRefreshing()
        loadPosts()
    }
    
    // posts loading function
    func loadPosts() {
        
        // load posts
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestname.last!)
        query.limit = page
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    
                    // hold found information in arrays
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    self.questArray.append(object.value(forKey: "questions") as! String)
                    
                }
                
                self.collectionView?.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // cell numb
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        // connect data from array to picImg object from pictureCell class
        picArray[indexPath.row].getDataInBackground (block: { (data, error) -> Void in
            if error == nil {
                cell.picimg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        })
        
        return cell
    }
    
    
    // header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerVC //connect to the header
        
        
        // STEP 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestname.last!)
        infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // shown wrong user
                if objects!.isEmpty {
                    // call alert
                    let alert = UIAlertController(title: "\(guestname.last!.uppercased())", message: "is not existing", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                
                // find related to user information
                for object in objects! {
                    header.usrname.text = (object.object(forKey: "fullname") as? String)?.uppercased()
                    header.descrip.text = object.object(forKey: "descrip") as? String
                    //header.bioLbl.sizeToFit()
                    //header.webTxt.text = object.object(forKey: "web") as? String
                    //header.webTxt.sizeToFit()
                    let avaFile : PFFile = (object.object(forKey: "profpic") as? PFFile)!
                    avaFile.getDataInBackground(block: { (data, error) -> Void in
                        header.prof.image = UIImage(data: data!)
                    })
                }
                
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        
        // STEP 2. Show do current user follow guest or do not
        let friendQuery = PFQuery(className: "friend")
        friendQuery.whereKey("from", equalTo: PFUser.current()!.username!)
        friendQuery.whereKey("to", equalTo: guestname.last!)
        friendQuery.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                if count == 0 {
                    header.button.setTitle("befriend", for: UIControlState()) //assume we have the friend button
                    header.button.backgroundColor = .lightGray
                } else {
                    header.button.setTitle("friended", for: UIControlState())
                    header.button.backgroundColor = .green
                }
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        
        // STEP 3. Count statistics
        // count posts //if we are counting scores
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname.last!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.post.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        // count followers if we are counting friend
        let followers = PFQuery(className: "friend")
        followers.whereKey("to", equalTo: guestname.last!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followers.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        /*
        // count followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guestname.last!)
        followings.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followings.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        */
        
        // STEP 4. Implement tap gestures
        // tap to posts label
        /* optional implementation
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.post.isUserInteractionEnabled = true
        header.post.addGestureRecognizer(postsTap)
        
        // tap to followers label
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.friend.isUserInteractionEnabled = true
        header.friend.addGestureRecognizer(followersTap)
        
        // tap to followings label
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.tofriend.isUserInteractionEnabled = true
        header.tofriend.addGestureRecognizer(followingsTap)
        
        */
        return header
    }


    
    // back function
    func back(_ sender : UIBarButtonItem) {
        
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean guest username or deduct the last guest userame from guestname = Array
        if !guestname.isEmpty {
            guestname.removeLast()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
