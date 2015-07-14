//
//  MyPostsViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/10/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import Parse

class MyPostsViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!
    var searchResults : [PFObject]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.queryPosts()
    }
    
    func queryPosts(){
        var query = PFQuery(className: "Post")
        query.whereKey("author", equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            if(error != nil){
                print(error)
            }
            else{
                if(results != nil){
                    self.searchResults = results as? [PFObject]
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.searchResults != nil){
            return self.searchResults!.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("myPostCell", forIndexPath: indexPath) as! myPostCell
        
        if let items = searchResults{
            cell.titleLabel.text = items[indexPath.row].objectForKey("title") as? String
            cell.bodyLabel.text = items[indexPath.row].objectForKey("body") as? String
            cell.object = items[indexPath.row]
        }
        
        return cell
    }
}

class myPostCell : UICollectionViewCell{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    var object : PFObject!
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        object.deleteInBackgroundWithBlock(nil)
    }
}
