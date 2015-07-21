//
//  AppLauncherViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/20/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit

class AppLauncherDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("defaultApp", forIndexPath: indexPath) as! UICollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        
//        let myURL = NSURL(string: fullURL)
//        UIApplication.sharedApplication().openURL(myURL!)
    }
    
}