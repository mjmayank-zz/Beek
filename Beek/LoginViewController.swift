//
//  LoginViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/9/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import Parse

class LoginViewController : UIViewController{
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(usernameTextField.text, password: passwordTextField.text) { (user:PFUser?, error:NSError?) -> Void in
            if(error == nil){
                self.performSegueWithIdentifier("toFeed", sender: self)
            }
            else{
                println(error)
                var alert = UIAlertController(title: "Error", message: "Try doing something else", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        if(passwordTextField.text == confirmPasswordTextField.text){
            var user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            user.signUpInBackgroundWithBlock({ (bool:Bool, error:NSError?) -> Void in
                if((error) != nil){
                    println(error)
                }
                else{
                    self.performSegueWithIdentifier("toFeed", sender: self)
                }
            })
            
        }
    }
}