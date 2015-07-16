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
        UserModel.logoutUser()
        self.navigationController?.popToRootViewControllerAnimated(false)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit{
        
    }
}