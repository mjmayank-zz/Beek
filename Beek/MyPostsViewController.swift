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

class MyPostsViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, myPostCellDelegate {
    @IBOutlet var collectionView: UICollectionView!
    var searchResults : [PFObject]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.queryPosts()
    }
    
    func queryPosts(){
        let query = PFQuery(className: "Post")
        query.whereKey("author", equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock { (results:[PFObject]?, error:NSError?) -> Void in
            if(error != nil){
                print(error, terminator: "")
            }
            else{
                if(results != nil){
                    self.searchResults = results
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("myPostCell", forIndexPath: indexPath) as! myPostCell
        
        if let items = searchResults{
            cell.titleLabel.text = items[indexPath.row].objectForKey("title") as? String
            cell.bodyLabel.text = items[indexPath.row].objectForKey("body") as? String
            cell.object = items[indexPath.row]
            cell.delegate = self
        }
        
        return cell
    }
    
    func deleteObject(object: PFObject){
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction) -> Void in
                object.deleteInBackgroundWithBlock(nil)
            self.queryPosts()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

class myPostCell : UICollectionViewCell, UIAlertViewDelegate{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    var object : PFObject!
    var delegate: myPostCellDelegate?
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        if let del = delegate{
            delegate?.deleteObject(object)
        }
    }
}

protocol myPostCellDelegate {
    func deleteObject(object: PFObject)
}