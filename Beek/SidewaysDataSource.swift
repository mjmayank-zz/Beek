//
//  FoursquareModuleViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/10/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class FoursquareView: NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("sidewaysCell", forIndexPath: indexPath) as! UICollectionViewCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 6
        cell.layer.borderWidth=2.0;
        cell.layer.borderColor = UIColor.blueColor().CGColor;
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}