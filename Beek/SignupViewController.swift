//
//  SignupViewController.swift
//  Beek
//
//  Created by Mayank Jain on 9/1/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController : UIViewController{
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        if(passwordTextField.text == confirmPasswordTextField.text){
            var user = PFUser()
            user.username = usernameTextField.text.lowercaseString
            user.password = passwordTextField.text
            user.setObject(firstNameTextField.text, forKey: "first_name")
            user.setObject(lastNameTextField.text, forKey: "last_name")
            user.setObject(emailTextField.text, forKey: "email")
            user.signUpInBackgroundWithBlock({ (bool:Bool, error:NSError?) -> Void in
                if((error) != nil){
                    println(error)
                    var message = error!.userInfo as! [String: AnyObject]
                    var alert = UIAlertController(title: "Error", message: message["NSLocalizedDescription"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    self.performSegueWithIdentifier("toFeed", sender: self)
                }
            })
            
        }
    }
    
    deinit{
        
    }
}