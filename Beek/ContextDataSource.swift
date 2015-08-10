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
    var collectionView : UICollectionView?
    var viewController : UIViewController?
    var selectedIndex : NSIndexPath?
    var cache = NSCache()
    
    init(type: String, id: String){
        super.init()
        self.searchResults = [PFObject]()
        
        cache.countLimit = 50
        
        var query = PFQuery(className: "Posts")
        query.whereKey(type, equalTo: id)
        query.findObjectsInBackgroundWithBlock({ (posts:[AnyObject]?, error:NSError?) -> Void in
            if let posts = posts{
                for post in posts{
                    self.searchResults?.append(post as! PFObject)
                }
                if let collectionView = self.collectionView{
                    collectionView.reloadData()
                }
            }
        })
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
            
            let itemID = item.objectId
            
            if(item.objectForKey("image") == nil){
                cell.backgroundImage.hidden = true
                cell.overlayView.hidden = true
            }
            else{
                cell.backgroundImage.hidden = false
                cell.overlayView.hidden = false
                if((self.cache.objectForKey(item.objectId!)) != nil){
                    cell.backgroundImage.image = self.cache.objectForKey(item.objectId!) as? UIImage
                }
                else{
                    if let file : PFFile = item.objectForKey("image") as? PFFile{
                        file.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                            if(error != nil){
                                
                            }
                            else{
                                var file = data
                                var bgImage = UIImage(data: file!)
                                self.cache.setObject(bgImage!, forKey: itemID!)
                                cell.backgroundImage.image = bgImage
                            }
                        })
                    }
                }
            }
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
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var overlayView: UIView!
}

class Context {
    var title : String?
    var subtitle : String?
}