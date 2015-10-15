//
//  TimePickerDataSource.swift
//  Beek
//
//  Created by Mayank Jain on 7/31/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TimePickerDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var timeList : [AnyObject]?
    var selectedObj : PFObject?
    var selectedIndex : NSIndexPath?
    var contextManager = ContextManager.sharedInstance
    
    override init() {
        super.init()
        timeList = contextManager.timesList
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let timeList = timeList{
            return timeList.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("timePickerCell", forIndexPath: indexPath) as! PickerCell
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 6
        
        if let timeList = timeList{
            let item = timeList[indexPath.row] as! PFObject
            cell.titleLabel.text = item.objectForKey("title") as? String
            
            if indexPath == selectedIndex{
                cell.backgroundColor = UIColor(red: 194/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
            }
            else{
                cell.backgroundColor = UIColor(red: 59/255.0, green: 119.0/255.0, blue: 182.0/255.0, alpha: 1.0)
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let timeList = timeList{
            self.selectedObj = timeList[indexPath.row] as? PFObject
            self.selectedIndex = indexPath
            collectionView.reloadData()
        }
    }
    
    //    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    //        return CGSize(width:100, height:collectionView.bounds.height)
    //    }
}