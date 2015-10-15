//
//  SettingsViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/14/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController{
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            UserModel.logoutUser()
            self.navigationController?.popToRootViewControllerAnimated(false)
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("loginViewController") 
            self.presentViewController(vc, animated: true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit{
        
    }
}