//
//  homeVC.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/13/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

class homeVC: UICollectionViewController {
    // refresher variable
    var refresher : UIRefreshControl!
    // how many pictures will be shown when first loaded - so maybe 8?
    var page : Int = 8
    
    // arrays to hold server information
    var uuidArray = [String]() //description/related information
    var picArray = [PFFile]() //picture
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // title at the top username on navigation bar
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        // background color
        collectionView?.backgroundColor = .white
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)

        
        // load posts func
        loadPosts()
        
        // always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        // receive notification from editVC
        NotificationCenter.default.addObserver(self, selector: #selector(homeVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    //reloading function after receive notification
    func uploaded(_ notification:Notification) {
        loadPosts()
        
    }
    
    // load more while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            loadMore()
        }
    }
    
    
    // paging
    func loadMore() {
        
        // if there is more objects
        if page <= picArray.count {
            
            // increase page size
            page = page + 12
            
            // load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: PFUser.current()!.username!)
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    }
                    
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
        }
        
    }

    // refreshing func
    func refresh() {
        
        // reload posts
        loadPosts()
        
        // stop refresher animating
        refresher.endRefreshing()
    }
    
    // load posts func (for now just assume parse dashboard is working and there are classes with following columns: posts, username,
    func loadPosts() {
        
        // request infomration from server
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!) //find matched username - want all posts from current user
        query.limit = page //limit loading - only showing 8 pics first
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                // find objects related to our request
                for object in objects! {
                    
                    // add found data to arrays (holders)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String) //uuid array will hold all values from uuid column in database of current user
                    self.picArray.append(object.value(forKey: "pic") as! PFFile) //get picture
                }
                
                self.collectionView?.reloadData() //now reload data
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerVC
        
        
        // STEP 1. Get user data
        // get users data with connections to collumns of PFuser class
        header.usrname.text = (PFUser.current()?.object(forKey: "username") as? String)?.uppercased()
        
       
        //header.descrip.text = PFUser.current()?.object(forKey: "bio") as? String
        //header.bioLbl.sizeToFit()
        let avaQuery = PFUser.current()?.object(forKey: "profpic") as! PFFile
        avaQuery.getDataInBackground { (data, error) -> Void in
            header.prof.image = UIImage(data: data!)
        }
        header.editprof.setTitle("edit profile", for: UIControlState())
        
        
        // STEP 2. Count statistics
        // count total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.post.text = "\(count)"
            }
        })
        // count total followers - dont have to implement this part for now if we are not doing followers - but assume we have followers database
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in //count followers
            if error == nil {
                header.followers.text = "\(count)" //no followers label that's why theres error
            }
        })

        //assume there is a pick database maybe
        // STEP 3. Implement tap gestures
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.post.isUserInteractionEnabled = true
        header.post.addGestureRecognizer(postsTap)
        /*
        // tap friend if we have one
        let friendTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.friendTap))
        friendTap.numberOfTapsRequired = 1
        header.friend.isUserInteractionEnabled = true
        header.friend.addGestureRecognizer(friendTap)
        
        // tap followings if we are implementing followers/following - 
         //but maybe for picks we can do picks they saved?
         
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        */
        return header
    }
    // taped posts label
    func postsTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    /*// tapped friend label if we make one
    func friendTap() {
        
        //user = PFUser.current()!.username!
        //category = "friend"
        
        // make references to friendVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "friendVC") as! friendVC - make reference to stodyboard
        
        // present
        self.navigationController?.pushViewController(friends, animated: true) present the referenced storyboard - present picks
    }


 */   /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    //override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
      //  return 0
    //}


    // cell numb
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 2, height: self.view.frame.size.width / 2)
        return size
    }
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCell //access variable from picturecell
        
        // get picture from the picArray
        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.picimg.image = UIImage(data: data!) //receive the data
            }
        }
        
        return cell
    }
    
    // go to post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }



/*
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
 */

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
