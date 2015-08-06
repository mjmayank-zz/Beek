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
    
    var placesList : [GMSPlaceLikelihood]?
    var selectedPlace : GMSPlace?
    var selectedIndex : NSIndexPath?
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = placesList{
            return array.count
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("placePickerCell", forIndexPath: indexPath) as! PickerCell
        
        if let items = placesList{
            let item : GMSPlace = items[indexPath.row].place
            cell.titleLabel.text = item.name
        }
        
        if indexPath == selectedIndex{
            cell.backgroundColor = UIColor.greenColor()
        }
        else{
            cell.backgroundColor = UIColor.blueColor()
        }
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 6
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let placesList = self.placesList{
            self.selectedPlace = placesList[indexPath.row].place
            self.selectedIndex = indexPath
            collectionView.reloadData()
        }
    }
    
    //    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    //        return CGSize(width:100, height:collectionView.bounds.height)
    //    }
}

class PickerCell : UICollectionViewCell{
    @IBOutlet var titleLabel: UILabel!
}