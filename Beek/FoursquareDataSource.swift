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

typealias JSONParameters = [String: AnyObject]

class FoursquareView: NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var venueItems : [JSONParameters]?
    var selectedItem : NSIndexPath?
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = venueItems{
            return array.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("sidewaysCell", forIndexPath: indexPath) as! foursquareCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 6
        cell.layer.borderWidth=2.0;
        cell.layer.borderColor = UIColor(red: 249/255, green: 72/255, blue: 119/255, alpha: 1.0).CGColor
//        cell.layer.borderColor = UIColor.blueColor().CGColor;
        
        cell.typeLabel.text = "--"
        cell.rating.text = "--"
        
        let item = self.venueItems![indexPath.row] as JSONParameters!
        
        if let venueInfo = item["venue"] as? JSONParameters{
            cell.titleLabel.text = venueInfo["name"] as? String
            if let categoryArray = venueInfo["categories"] as? [JSONParameters]{
                if let category = categoryArray[0]["name"] as? String{
                    cell.typeLabel.text = category
                }
            }
            if let rating = venueInfo["rating"] as? Double{
                cell.rating.text = rating.description
            }
        }
        
        if(selectedItem == indexPath){
            cell.backgroundColor = UIColor(red: 18/255, green: 152/255, blue: 232/155, alpha: 1.0)
        }
        else{
            cell.backgroundColor = UIColor.whiteColor()
        }
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if(selectedItem == indexPath){
            selectedItem = nil
        }
        else{
            selectedItem = indexPath
        }
        collectionView.reloadData()
    }
    
    func getSelectedPlace() -> JSONParameters?{
        if let index = selectedItem{
            return venueItems![index.row]
        }
        return nil
    }
}

class foursquareCell : UICollectionViewCell{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var rating: UILabel!
}
