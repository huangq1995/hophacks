//
//  navVC.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/15/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit

class navVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // color of title at the top in nav controller
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // color of buttons in nav controller
        self.navigationBar.tintColor = .white
        
        // color of background of nav controller - i jsut picked a random color feel free to change it
        self.navigationBar.barTintColor = UIColor(red: 18.0 / 255.0, green: 86.0 / 255.0, blue: 136.0 / 255.0, alpha: 1)
        
        // disable translucent
        self.navigationBar.isTranslucent = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // white status bar function
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
