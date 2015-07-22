
//  AppLauncherViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/20/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import Parse

class AppLauncherDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
 
    var manager : CLLocationManager!
    var array: [String] = NSUserDefaults.standardUserDefaults().objectForKey("apps")! as! [String]
    var dict = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Apps", ofType: "plist")!)!
    
    init(manager: CLLocationManager) {
        array = dict.allKeys as! [String]
        self.manager = manager
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
        var launch = PFObject(className: "AppLaunch")
        launch.setObject(array[indexPath.row], forKey: "app")
        launch.setObject(PFUser.currentUser()!, forKey: "user")
        var geoPoint = PFGeoPoint(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude)
        launch.setObject(geoPoint, forKey: "location")
        launch.saveInBackgroundWithBlock(nil)
        
        let item : AnyObject = dict[array[indexPath.row]]!
        let url : String = item["url_scheme"] as! String
        let myURL = NSURL(string: url)
        UIApplication.sharedApplication().openURL(myURL!)
    }
    
}

class AppCell: UICollectionViewCell {
    @IBOutlet var iconImageView: UIImageView!
}