//
//  SignUpViewController.swift
//  Pikit
//
//  Created by Qinwen Huang on 2/12/17.
//  Copyright © 2017 Qinwen Huang. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //profile image
    @IBOutlet weak var profpic: UIImageView!
   //textfields
    @IBOutlet weak var usrnametxt: UITextField!
    @IBOutlet weak var pwdtxt: UITextField!
    
    
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var signupbtn: UIButton!
    @IBOutlet weak var cancelbtn: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var repeatpwdtxt: UITextField!
    //reset default size
    var scrollViewHeight: CGFloat = 0
    //keyboard frame size
    var keyboard = CGRect()
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scroll.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scroll.contentSize.height = self.view.frame.height
        scrollViewHeight = scroll.frame.size.height
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        nc.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        // declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        // declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        profpic.isUserInteractionEnabled = true
        profpic.addGestureRecognizer(avaTap)
       
        // round profpif
        profpic.layer.cornerRadius = profpic.frame.size.width / 2
        profpic.clipsToBounds = true
        // alignment
        profpic.frame = CGRect(x: self.view.frame.size.width / 2 - 40, y: 40, width: 80, height: 80)
        usrnametxt.frame = CGRect(x: 15, y: profpic.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 30)
        pwdtxt.frame = CGRect(x: 15, y: usrnametxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        repeatpwdtxt.frame = CGRect(x: 15, y: pwdtxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        emailtxt.frame = CGRect(x: 15, y: repeatpwdtxt.frame.origin.y + 60, width: self.view.frame.size.width - 20, height: 30)
        //fullnameTxt.frame = CGRect(x: 10, y: emailtxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        //bioTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        //webTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        
        signupbtn.frame = CGRect(x: 20, y: emailtxt.frame.origin.y + 50, width: self.view.frame.size.width / 4, height: 30)
        signupbtn.layer.cornerRadius = signupbtn.frame.size.width / 20
        
        cancelbtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signupbtn.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        cancelbtn.layer.cornerRadius = cancelbtn.frame.size.width / 20

        
    }
    
    // connect selected image to our ImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profpic.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    //select image
    func loadImg(_ recognizer:UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        // define keyboard size
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        // move up UI
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scroll.frame.size.height = self.scrollViewHeight - self.keyboard.height
        })

    }
    // hide keyboard func
    func keyboardWillHide(_ notification:Notification) {
        
        // move down UI
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scroll.frame.size.height = self.view.frame.height
        })
    }

    
    //click to sign up
    @IBAction func signupact(_ sender: Any) {
        print("signup pressed")
        
        //dismiss keyboard
        self.view.endEditing(true)
        
        //if fields are empty
        if (usrnametxt.text!.isEmpty || pwdtxt.text!.isEmpty || repeatpwdtxt.text!.isEmpty || emailtxt.text!.isEmpty) {
            // alert message
            let alert = UIAlertController(title: "PLEASE", message: "fill all fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //if password doesnt match
        if pwdtxt.text != repeatpwdtxt.text {
            print("'\(pwdtxt)' '\(repeatpwdtxt)'")
            // alert message
            let alert = UIAlertController(title: "PASSWORDS", message: "do not match", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //send data to server to relate columns
        let user = PFUser()
        user.username = usrnametxt.text?.lowercased()
        user.email = emailtxt.text?.lowercased()
        user.password = pwdtxt.text
        
        //if edit profile it's gonna get assigned
        user["tel"] = ""
        user["gender"]=""
        
        //convert image for sending to server
        
        let profpicData = UIImageJPEGRepresentation(profpic.image!, 0.5)
        let profpicFile = PFFile(name:"profilepic", data:profpicData!)
        user["profpic"] = profpicFile
        
        //save data in server
        user.signUpInBackground { (success, error) -> Void in
            if success {
                print("registered")
                
                // remember looged user
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login func from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            } else {
                
                // show alert message
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }

    }
    //click to cancel
    @IBAction func cancelact(_ sender: Any) {
        self.dismiss(animated: true, completion:nil )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
