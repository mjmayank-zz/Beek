//
//  ContextDataSource.swift
//  Beek
//
//  Created by Mayank Jain on 7/30/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit

class PlacePickerDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var placesList : [AnyObject]?
    var selectedPlace : GMSPlace?
    var selectedIndex : NSIndexPath?
    var contextManager = ContextManager.sharedInstance
    
    override init() {
        super.init()
        placesList = contextManager.placesList
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = placesList{
            return array.count
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("placePickerCell", forIndexPath: indexPath) as! PickerCell
        
        if let items = placesList{
            let item = items[indexPath.row] as! GMSPlace
            cell.titleLabel.text = item.name
            cell.titleLabel.sizeToFit()
        }
        
        if indexPath == selectedIndex{
            cell.backgroundColor = UIColor(red: 194/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        }
        else{
            cell.backgroundColor = UIColor(red: 59/255.0, green: 119.0/255.0, blue: 182.0/255.0, alpha: 1.0)
        }
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 6
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let placesList = self.placesList{
            self.selectedPlace = placesList[indexPath.row] as? GMSPlace
            self.selectedIndex = indexPath
            collectionView.reloadData()
        }
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        if let items = placesList{
//            let item = items[indexPath.row] as! GMSPlace
//            var length = count(item.name) - 15
//            return CGSize(width:120 + 3 * length, height:22)
//        }
//        return CGSize(width:120, height:22)
//    }
}

class PickerCell : UICollectionViewCell{
    @IBOutlet var titleLabel: UILabel!
}