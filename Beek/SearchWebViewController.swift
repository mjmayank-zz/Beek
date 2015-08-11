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
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.webView = WKWebView()
        self.containerView.addSubview(self.webView!)
        
        query = query.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        var fulladdress = "http://www.google.com/search?q=" + query
        var url = NSURL(string: fulladdress)
        var requestObj = NSURLRequest(URL: url!)
        self.webView!.loadRequest(requestObj)
        
//        var leftConstraint = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Left, multiplier: CGFloat(1.0), constant: CGFloat(0))
//        self.containerView.addConstraint(leftConstraint)
//        var topConstraint = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Top, multiplier: CGFloat(1.0), constant: CGFloat(0))
//        self.containerView.addConstraint(topConstraint)
//        var bottomConstraint = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Bottom, multiplier: CGFloat(1.0), constant: CGFloat(0))
//        self.containerView.addConstraint(bottomConstraint)
//        var rightConstraint = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Right, multiplier: CGFloat(1.0), constant: CGFloat(0))
//        self.containerView.addConstraint(rightConstraint)
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
    
    func screenShotMethod() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 0);
        self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true);
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        let cropped = cropImageToSquare(snapshotImage)
//        UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil)
        return cropped;
    }
    
    func cropImageToSquare(image: UIImage) -> UIImage{
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        let contextSize: CGSize = image.size
        // Check to see which length is the longest and create the offset based on that length, then set the width and height for our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX * image.scale, posY * image.scale, width * image.scale, height * image.scale)
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(image.CGImage, rect)
        // Create a new image based on the imageRef and rotate back to the original orientation
        let newimage: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)!
        
        return newimage
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(segue.identifier)
        if segue.identifier == "createPost"{
            var destVC = segue.destinationViewController as! CreatePostViewController
            var url:NSURL = self.webView!.URL!
            destVC.postURL = url.absoluteString
            destVC.image = screenShotMethod()
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.webView?.goBack()
    }
    
    @IBAction func forwardButtonPressed(sender: AnyObject) {
        self.webView?.goForward()
    }
    @IBAction func shareButtonPressed(sender: AnyObject) {
        if let webView = self.webView{
            if let url = webView.URL{
                let objectsToShare = [url]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        }
    }
}