//
//  SearchWebView.swift
//  Beek
//
//  Created by Mayank Jain on 7/13/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class SearchWebViewController: UIViewController{
    private var webView: WKWebView?
    var query : String!
    //    @IBOutlet var webView: UIWebView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView = WKWebView()
        self.containerView.addSubview(self.webView!)
//        self.webView?.frame = self.view.bounds
//        self.containerView.insertSubview(self.webView!, atIndex: 0)
//        self.containerView = self.webView
        
        query = query.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        var fulladdress = "http://www.google.com/search?q=" + query
        
        var url = NSURL(string: fulladdress)
        var requestObj = NSURLRequest(URL: url!)
        self.webView!.loadRequest(requestObj)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.webView!.frame = self.containerView.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(segue.identifier)
        if segue.identifier == "createPost"{
            var destVC = segue.destinationViewController as! CreatePostViewController
            var url:NSURL = self.webView!.URL!
            destVC.postURL = url.absoluteString
        }
    }
}