//
//  TimePickerDataSource.swift
//  Beek
//
//  Created by Mayank Jain on 7/31/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit

class TimePickerDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var timeList : [PFObject]?
    var selectedObj : PFObject?
    var selectedIndex : NSIndexPath?
    
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
            let item = timeList[indexPath.row]
            cell.titleLabel.text = item.objectForKey("title") as? String
            
            if indexPath == selectedIndex{
                cell.backgroundColor = UIColor.greenColor()
            }
            else{
                cell.backgroundColor = UIColor.blueColor()
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let timeList = timeList{
            self.selectedObj = timeList[indexPath.row]
            self.selectedIndex = indexPath
            collectionView.reloadData()
        }
    }
    
    //    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    //        return CGSize(width:100, height:collectionView.bounds.height)
    //    }
}