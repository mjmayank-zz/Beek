//
//  ContextDataSource.swift
//  Beek
//
//  Created by Mayank Jain on 7/27/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit

class ContextDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var context : Context?
    var searchResults : [PFObject]?
    var viewController : UIViewController?
    var selectedIndex : NSIndexPath?
    
    init(results: [AnyObject]){
        super.init()
        self.searchResults = [PFObject]()
        for result in results{
            self.searchResults?.append(result as! PFObject)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = searchResults{
            return array.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("contextResultCell", forIndexPath: indexPath) as! contextCell
        
        if let items = searchResults{
            let item : PFObject = items[indexPath.row]
            cell.titleLabel.text = item.objectForKey("title") as? String
            cell.bodyLabel.text = item.objectForKey("body") as? String
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndex = indexPath
        if let items = searchResults{
            if items[indexPath.row].objectForKey("url") as? String != nil && items[indexPath.row].objectForKey("url") as? String != ""{
                var fullURL = ""
                if let url = items[indexPath.row].objectForKey("url") as? String{
                    fullURL = url
                }
                let endIndex = advance(fullURL.startIndex, 4)
                var start = fullURL.substringToIndex(endIndex)
                if(start == "http"){
                    if let vc = self.viewController{
                        vc.performSegueWithIdentifier("toWebView", sender: self)
                    }
                }
                else{
                    //how to launch an app
                    let myURL = NSURL(string: fullURL)
                    UIApplication.sharedApplication().openURL(myURL!)
                }
            }
            else{
                if let vc = self.viewController{
                    vc.performSegueWithIdentifier("toDetail", sender: self)
                }
            }
        }
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width:100, height:collectionView.bounds.height)
//    }
}

class contextCell : UICollectionViewCell{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
}

class Context {
    var title : String?
    var subtitle : String?
}