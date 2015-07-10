//
//  WebViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/10/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import Parse

class WebViewController : UIViewController {
    var detailObject : PFObject!
    
    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(detailObject)
        var fullURL = "http://"
        if let url = detailObject.objectForKey("url") as? String{
            fullURL += url
            println(fullURL)
        }
        else{
            fullURL += "google.com"
        }
        var url = NSURL(string: fullURL)
        var requestObj = NSURLRequest(URL: url!)
        self.webView.loadRequest(requestObj)
        
        //how to launch an app
        //        let myURL = NSURL(string: "flixster://")
        //        UIApplication.sharedApplication().openURL(myURL!)
    }
}
    