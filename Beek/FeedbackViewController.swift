//
//  FeedbackViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/10/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import Parse

class FeedbackViewController : UIViewController, UITextViewDelegate{
    
    @IBOutlet var helpLabel2: UILabel!
    @IBOutlet var helpLabel1: UILabel!
    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.becomeFirstResponder()
        self.textView.delegate = self
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        self.helpLabel1.hidden = textView.text != ""
        self.helpLabel2.hidden = textView.text != ""
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        let post = PFObject(className: "Feedback")
        post.setObject(self.textView.text, forKey: "body")
        post.setObject(PFUser.currentUser()!, forKey: "author")
        post.saveInBackgroundWithBlock { (bool:Bool, error:NSError?) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}