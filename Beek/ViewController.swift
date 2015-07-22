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
import QuadratTouch

class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate{

    let manager = CLLocationManager()
    var searchResults : [PFObject]?
    var oldLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    var refreshControl:UIRefreshControl!
    var fsDataSource = FoursquareView()
    var appsDataSource = AppLauncherDataSource()
    var searchesDataSource = SearchesDataSource()
    var cache = NSCache()
    var session : Session!
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var foursquareCollectionView: UICollectionView!
    @IBOutlet var appLauncher: UICollectionView!
    @IBOutlet var searchesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        session = Session.sharedSession()
        
        cache.countLimit = 50
        
        collectionView.delegate = self
        collectionView.dataSource = self
        foursquareCollectionView.dataSource = fsDataSource
        foursquareCollectionView.delegate = fsDataSource
        appLauncher.dataSource = appsDataSource
        appLauncher.delegate = appsDataSource
        searchesCollectionView.dataSource = searchesDataSource
        searchesCollectionView.delegate = searchesDataSource
        
        manager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(self.refreshControl)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.searchTextField.delegate = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let array = ["fb://", "twitter://", "mailto://", "sms://", "instagram://"]
        defaults.setObject(array, forKey: "apps")
        defaults.objectForKey("apps")
    }
    
    deinit{
        println("ViewController deinitializing")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let location = manager.location{
            self.queryObjects(location)
        }
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
        
        var searchesQuery = PFQuery(className: "Search")
        searchesQuery.whereKey("location", nearGeoPoint: point, withinMiles:1.0)
        searchesQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            if(error != nil){
                print(error)
            }
            else{
                if(results != nil){
                    self.searchesDataSource.searchResults = results as? [PFObject]
                }
            }
            self.searchesCollectionView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("localPostCell", forIndexPath: indexPath) as! localPostCell
            
            if let items = searchResults{
                let object :PFObject = items[indexPath.row]
                cell.label.text = items[indexPath.row].objectForKey("title") as? String
                cell.bodyLabel.text = items[indexPath.row].objectForKey("body") as? String
                cell.object = items[indexPath.row]
                
                let cell_key = object.objectId
                
                if(object.objectForKey("image") == nil){
                    cell.backgroundImage.hidden = true
                    cell.overlayView.hidden = true
                }
                else{
                    cell.backgroundImage.hidden = false
                    cell.overlayView.hidden = false
                    if((self.cache.objectForKey(object.objectId!)) != nil){
                        cell.backgroundImage.image = self.cache.objectForKey(object.objectId!) as? UIImage
                    }
                    else{
                        if let file : PFFile = object.objectForKey("image") as? PFFile{
                            file.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                                if(error != nil){
                                    
                                }
                                else{
                                    var file = data
                                    var bgImage = UIImage(data: file!)
                                    self.cache.setObject(bgImage!, forKey: cell_key!)
                                    cell.backgroundImage.image = bgImage
                                }
                            })
                        }
                    }
                }
            }
        
            return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let items = searchResults{
            if items[indexPath.row].objectForKey("url") as? String != nil && items[indexPath.row].objectForKey("url") as? String != ""{
                var fullURL = ""
                if let url = items[indexPath.row].objectForKey("url") as? String{
                    fullURL = url
                }
                let endIndex = advance(fullURL.startIndex, 4)
                var start = fullURL.substringToIndex(endIndex)
                if(start == "http"){
                    self.performSegueWithIdentifier("toWebView", sender: self)
                }
                else{
                    //how to launch an app
                    let myURL = NSURL(string: fullURL)
                    UIApplication.sharedApplication().openURL(myURL!)
                }
            }
            else{
                self.performSegueWithIdentifier("toDetail", sender: self)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if(self.view.bounds.width > 400){
            return CGSize(width:self.view.bounds.width/3-10, height:self.view.bounds.width/3-10)
        }
        return CGSize(width:self.view.bounds.width/2-10, height:self.view.bounds.width/2-10)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var newLocation = locations[0] as! CLLocation
        if(newLocation.distanceFromLocation(oldLocation) > 100){
            oldLocation = newLocation
            queryObjects(newLocation)
            let location = self.manager.location
            var parameters = location.parameters()
            parameters["radius"] = "500"
            let task = self.session.venues.explore(parameters) {
                (result) -> Void in
                if self.fsDataSource.venueItems != nil {
                    return
                }
                if !NSThread.isMainThread() {
                    fatalError("!!!")
                }
                
                if result.response != nil {
                    if let groups = result.response!["groups"] as? [[String: AnyObject]]  {
                        var venues = [[String: AnyObject]]()
                        for group in groups {
                            if let items = group["items"] as? [[String: AnyObject]] {
                                venues += items
                            }
                        }
                        
                        self.fsDataSource.venueItems = venues
                    }
                    //                print(self.venueItems)
                                    self.foursquareCollectionView.reloadData()
                } else if result.error != nil && !result.isCancelled() {
                    //                self.showErrorAlert(result.error!)
                }
            }
            task.start()
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
            if(self.searchTextField.text != ""){
                var search = PFObject(className: "Search")
                search.setObject(self.searchTextField.text, forKey: "searchValue")
                search.setObject(PFUser.currentUser()!, forKey: "user")
                var geoPoint = PFGeoPoint(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude)
                search.setObject(geoPoint, forKey: "location")
                search.saveInBackgroundWithBlock(nil)
            }
            self.searchTextField.resignFirstResponder()
            var destVC = segue.destinationViewController as! SearchWebViewController
            destVC.query = self.searchTextField.text
        }
        else if(segue.identifier == "suggestedSearched"){
            var destVC = segue.destinationViewController as! SearchWebViewController
            let cell = sender as! searchesCell
            destVC.query = cell.searchLabel.text
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.performSegueWithIdentifier("searched", sender: self)
        return true
    }
    
}

class localPostCell : UICollectionViewCell{
    @IBOutlet var label: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var overlayView: UIView!
    
    var object : PFObject!
}

extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}