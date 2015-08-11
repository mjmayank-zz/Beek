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
import QuadratTouch

class ViewController: UIViewController, ContextManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate{

    var oldLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    var refreshControl:UIRefreshControl!
    var fsDataSource = FoursquareView()
    var appsDataSource : AppLauncherDataSource!
    var searchesDataSource = SearchesDataSource()
    var contextDataSources = [ContextDataSource]()
    var session : Session!
    var contextManager = ContextManager.sharedInstance
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var foursquareCollectionView: UICollectionView!
    @IBOutlet var appLauncher: UICollectionView!
    @IBOutlet var searchesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appsDataSource = AppLauncherDataSource()
        
        session = Session.sharedSession()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        foursquareCollectionView.dataSource = fsDataSource
        foursquareCollectionView.delegate = fsDataSource
        foursquareCollectionView.scrollsToTop = false
        appLauncher.dataSource = appsDataSource
        appLauncher.delegate = appsDataSource
        appLauncher.scrollsToTop = false
        appsDataSource.delegate = self
        searchesCollectionView.dataSource = searchesDataSource
        searchesCollectionView.delegate = searchesDataSource
        searchesCollectionView.scrollsToTop = false
        
        contextManager.delegate = self
        
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
        if let location = contextManager.locationManager.location{
            if let oldLocation = self.oldLocation{
                if(location.distanceFromLocation(oldLocation) > 100){
                    self.oldLocation = location
                    self.queryObjects(location)
                }
            }
            else{
                self.oldLocation = location
                self.queryObjects(location)
            }
        }
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return scrollView == self.collectionView
    }

    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        contextManager.refresh()
        queryObjects(contextManager.locationManager.location)
        self.refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int{
            return self.contextDataSources.count
    }
    
    func queryObjects(location: CLLocation!){
        var point = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        var searchesQuery = PFQuery(className: "Search")
        searchesQuery.whereKey("location", nearGeoPoint: point, withinMiles:0.5)
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("contextCardCell", forIndexPath: indexPath) as! contextCardCell
            var ds = contextDataSources[indexPath.row]
            cell.collectionView.dataSource = ds
            cell.collectionView.delegate = ds
            cell.collectionView.scrollsToTop = false
            cell.collectionView.reloadData()

            if let context = ds.context{
                cell.contextNameLabel.text = context.title
                cell.label.text = context.subtitle
            }
//            if(ds.searchResults?.count == 0){
//                cell.hidden = true
//            }
//            else{
//                cell.hidden = false
//            }
            
            
//            if let items = searchResults{
//                let object :PFObject = items[indexPath.row]
//                cell.label.text = items[indexPath.row].objectForKey("title") as? String
//                cell.bodyLabel.text = items[indexPath.row].objectForKey("body") as? String
//                cell.object = items[indexPath.row]
//                
//                let cell_key = object.objectId
//                
//                if(object.objectForKey("image") == nil){
//                    cell.backgroundImage.hidden = true
//                    cell.overlayView.hidden = true
//                }
//                else{
//                    cell.backgroundImage.hidden = false
//                    cell.overlayView.hidden = false
//                    if((self.cache.objectForKey(object.objectId!)) != nil){
//                        cell.backgroundImage.image = self.cache.objectForKey(object.objectId!) as? UIImage
//                    }
//                    else{
//                        if let file : PFFile = object.objectForKey("image") as? PFFile{
//                            file.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
//                                if(error != nil){
//                                    
//                                }
//                                else{
//                                    var file = data
//                                    var bgImage = UIImage(data: file!)
//                                    self.cache.setObject(bgImage!, forKey: cell_key!)
//                                    cell.backgroundImage.image = bgImage
//                                }
//                            })
//                        }
//                    }
//                }
//            }
        
            return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        var ds = contextDataSources[indexPath.row]
//        if(ds.searchResults?.count == 0){
//            return CGSize(width:self.view.bounds.width, height:0)
//        }
        return CGSize(width:self.view.bounds.width, height:200)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var newLocation = locations.last as! CLLocation
        
        if(newLocation.distanceFromLocation(oldLocation) > 100){
            oldLocation = newLocation
            queryObjects(newLocation)
            let location = newLocation
            var parameters = location.parameters()
            parameters["radius"] = parameters["llAcc"]
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
            var cds = sender as! ContextDataSource
            destVC.detailObject =   PostModel(object:cds.searchResults![cds.selectedIndex!.row])
        }
        else if(segue.identifier == "toWebView"){
            var destVC = segue.destinationViewController as! WebViewController
            var cds = sender as! ContextDataSource
            destVC.detailObject = PostModel(object: cds.searchResults![cds.selectedIndex!.row])
        }
        
        else if(segue.identifier == "searched"){
            if(self.searchTextField.text != ""){
                if let location = contextManager.locationManager.location{
                    var search = PFObject(className: "Search")
                    search.setObject(self.searchTextField.text, forKey: "searchValue")
                    search.setObject(PFUser.currentUser()!, forKey: "user")
                    var geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    search.setObject(geoPoint, forKey: "location")
                    
                    var item : [String: AnyObject]? = fsDataSource.getSelectedPlace()
                    if item != nil{
                        if let venueInfo = item!["venue"] as? [String : AnyObject]{
                            search.setObject(venueInfo["id"]!, forKey: "foursqure_id")
                            search.setObject(venueInfo["name"] as! String, forKey: "venue_name")
                            if let categoryArray = venueInfo["categories"] as? [JSONParameters]{
                                search.setObject(categoryArray[0]["name"]!, forKey: "venue_category")
                            }
                        }
                    }
                    search.saveInBackgroundWithBlock(nil)
                }
            }
            self.searchTextField.resignFirstResponder()
            var destVC = segue.destinationViewController as! SearchWebViewController
            destVC.query = self.searchTextField.text
            self.searchTextField.text = ""
        }
        else if(segue.identifier == "suggestedSearched"){
            var destVC = segue.destinationViewController as! SearchWebViewController
            let cell = sender as! searchesCell
            destVC.query = cell.searchLabel.text
        }
        else if(segue.identifier == "feedToCreatePost"){
            let destVC = segue.destinationViewController as! CreatePostViewController
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.performSegueWithIdentifier("searched", sender: self)
        return true
    }
    
    func didUpdateContext(context: String, withItems items: [AnyObject]) {
        if context == "places"{
            self.contextDataSources = [ContextDataSource]()
            for (index, item) in enumerate(items){
                var place = item as! GMSPlace
                var context = Context()
                context.title = place.name
                if index == 0{
                    context.subtitle = "Because you're at"
                }
                else{
                    context.subtitle = "Because you're near"
                }
                let cds = ContextDataSource(type: "googlePlacesId", id: place.placeID)
                cds.context = context
                cds.collectionView = self.collectionView
                cds.viewController = self
                self.contextDataSources.append(cds)
            }
            self.collectionView.reloadData()
        }
        if context == "times"{
            
        }
    }
}

class contextCardCell : UICollectionViewCell{
    @IBOutlet var label: UILabel!
    @IBOutlet var contextNameLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
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

extension String {
    
    /// Percent escape value to be added to a URL query value as specified in RFC 3986
    ///
    /// This percent-escapes all characters besize the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Return precent escaped string.
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
    
}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = map(self) { (key, value) -> String in
            let percentEscapedKey = (key as? String)!.stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as? String)!.stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return join("&", parameterArray)
    }
    
}

