//
//  WebViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/10/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController : UIViewController {
    var detailObject : PostModel!
    private var webView: WKWebView?

//    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        
        view = webView
        
        var fullURL:String = ""
        if let url = detailObject.url{
            fullURL = url
        }
        let endIndex = advance(fullURL.startIndex, 4)
        var start = fullURL.substringToIndex(endIndex)
        var url = NSURL(string: fullURL)
        var requestObj = NSURLRequest(URL: url!)
        self.webView!.loadRequest(requestObj)
        
    }
}
    