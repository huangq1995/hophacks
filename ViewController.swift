//
//  ViewController.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/12/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit

import Parse

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let object = PFObject(className: "testobject")
        object["name"] = "B"
        object["lastname"] = "tt"
        object.saveInBackground { (done:Bool, error:Error?) -> Void in
            if done {
                print("Saved")
                
            } else {
                print("error")
            }
        }
    }
        
        
}

   // override func didReceiveMemoryWarning() {
     //   super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    //}



