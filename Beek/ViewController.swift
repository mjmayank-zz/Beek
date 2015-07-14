//
//  ViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/9/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Parse

class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    let manager = CLLocationManager()
    var searchResults : [PFObject]?
    var oldLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    var refreshControl:UIRefreshControl!
    var dataSource = FoursquareView()

    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var foursquareCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        foursquareCollectionView.dataSource = dataSource
        foursquareCollectionView.delegate = dataSource
        
        manager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(self.refreshControl)
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.queryObjects(manager.location)
    }

    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        queryObjects(manager.location)
        self.refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int{
            if (self.searchResults != nil){
                return self.searchResults!.count
            }
            return 0
    }
    
    func queryObjects(location: CLLocation!){
        if(location == nil){
            return
        }
        var query = PFQuery(className: "Post")
        var point = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        query.whereKey("location", nearGeoPoint: point, withinMiles:1.0)
        
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
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("foursquareCell", forIndexPath: indexPath) as! foursquareCell
            if let items = searchResults{
                cell.label.text = items[indexPath.row].objectForKey("title") as? String
                cell.bodyLabel.text = items[indexPath.row].objectForKey("body") as? String
                cell.object = items[indexPath.row]
            }
            if(indexPath.row % 2 == 0){
                cell.backgroundImage.image = UIImage(named: "baja_fresh.png")
            }
            else{
                cell.backgroundImage.image = UIImage(named: "teoco.png")

            }
            //            var object = PFObject(className: "Venue")
            //            object.setValue(venueInfo!["name"] as? String, forKey: "name")
            //            object.setValue(venueInfo!["id"] as? String, forKey: "foursquareID")
            //            object.save()
            return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let items = searchResults{
            if items[indexPath.row].objectForKey("url") as? String != nil{
                self.performSegueWithIdentifier("toWebView", sender: self)
            }
            else{
                self.performSegueWithIdentifier("toDetail", sender: self)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var newLocation = locations[0] as! CLLocation
        if(newLocation.distanceFromLocation(oldLocation) > 100){
            oldLocation = newLocation
            queryObjects(newLocation)
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchTextField.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(segue.identifier)
        if segue.identifier == "toDetail"{
            var destVC = segue.destinationViewController as! DetailViewController
            destVC.detailObject = PostModel(object:self.searchResults![collectionView.indexPathsForSelectedItems()[0].row])
        }
        else if(segue.identifier == "toWebView"){
            var destVC = segue.destinationViewController as! WebViewController
            destVC.detailObject = PostModel(object: self.searchResults![collectionView.indexPathsForSelectedItems()[0].row])
        }
        
        else if(segue.identifier == "searched"){
            var search = PFObject(className: "Search")
            search.setObject(self.searchTextField.text, forKey: "searchValue")
            search.setObject(PFUser.currentUser()!, forKey: "user")
            var geoPoint = PFGeoPoint(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude)
            search.setObject(geoPoint, forKey: "location")
            search.saveInBackgroundWithBlock(nil)
            
            self.searchTextField.resignFirstResponder()
            var destVC = segue.destinationViewController as! SearchWebViewController
            destVC.query = self.searchTextField.text
        }
    }
    
}

class foursquareCell : UICollectionViewCell{
    @IBOutlet var label: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    var object : PFObject!
}