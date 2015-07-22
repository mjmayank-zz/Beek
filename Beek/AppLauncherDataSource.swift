
//  AppLauncherViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/20/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit

class AppLauncherDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
 
    
    var array: [String] = NSUserDefaults.standardUserDefaults().objectForKey("apps")! as! [String]
    var dict = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Apps", ofType: "plist")!)!
    
    override init() {
        array = dict.allKeys as! [String]
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("defaultApp", forIndexPath: indexPath) as! AppCell
        let item : AnyObject = dict[array[indexPath.row]]!
        let fileName : String = item["image"] as! String
        cell.iconImageView.image = UIImage(named: fileName)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item : AnyObject = dict[array[indexPath.row]]!
        let url : String = item["url_scheme"] as! String
        let myURL = NSURL(string: url)
        UIApplication.sharedApplication().openURL(myURL!)
    }
    
}

class AppCell: UICollectionViewCell {
    @IBOutlet var iconImageView: UIImageView!
}