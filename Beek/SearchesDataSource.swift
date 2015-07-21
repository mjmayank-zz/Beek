//
//  SearchesDataSource.swift
//  Beek
//
//  Created by Mayank Jain on 7/20/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SearchesDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var searchResults : [PFObject]?
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = searchResults{
            return array.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("searchesCell", forIndexPath: indexPath) as! searchesCell
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 6
        cell.layer.borderWidth=2.0;
        cell.layer.borderColor = UIColor.blackColor().CGColor
        
        if let items = searchResults{
            cell.searchLabel.text = items[indexPath.row].objectForKey("searchValue") as? String
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        var destVC = segue.destinationViewController as! SearchWebViewController
//        destVC.query = self.searchTextField.text
    }
}

class searchesCell : UICollectionViewCell{
    @IBOutlet var searchLabel: UILabel!
    
}