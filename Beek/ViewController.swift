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

class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate{

    let manager = CLLocationManager()
    var likelihoods : [GMSPlaceLikelihood]?
    var oldLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    var refreshControl:UIRefreshControl!
    var fsDataSource = FoursquareView()
    var appsDataSource : AppLauncherDataSource!
    var searchesDataSource = SearchesDataSource()
    var contextDataSources = [ContextDataSource]()
    var cache = NSCache()
    var session : Session!
    let placesClient = GMSPlacesClient()
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var foursquareCollectionView: UICollectionView!
    @IBOutlet var appLauncher: UICollectionView!
    @IBOutlet var searchesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appsDataSource = AppLauncherDataSource(manager: manager)
        
        session = Session.sharedSession()
        
        cache.countLimit = 50
        
        collectionView.delegate = self
        collectionView.dataSource = self
        foursquareCollectionView.dataSource = fsDataSource
        foursquareCollectionView.delegate = fsDataSource
        appLauncher.dataSource = appsDataSource
        appLauncher.delegate = appsDataSource
        appsDataSource.delegate = self
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
            return self.contextDataSources.count
    }
    
    func queryObjects(location: CLLocation!){
        if(location == nil){
            return
        }
        
        var parameterString = [String : AnyObject]()
        parameterString["location"] = String(format:"%f,%f", location.coordinate.latitude, location.coordinate.longitude)
        parameterString["radius"] = String(format:"%f",location.horizontalAccuracy)
        parameterString["key"] = "AIzaSyAr8JVdMDs82_bUCQtPrkNyq7XuikcmkhQ"
        let string = parameterString.stringFromHttpParameters()
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?\(string)")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            let json = JSON(data: data)
        }
        
        task.resume()
        
        self.contextDataSources = [ContextDataSource]()
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                println("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLicklihoodList = placeLikelihoodList {
                self.likelihoods = placeLicklihoodList.likelihoods as? [GMSPlaceLikelihood]
                for (index, likelihood) in enumerate(self.likelihoods!){
                    var accuracy = location.horizontalAccuracy > 50 ? location.horizontalAccuracy : 50
                    if (location.distanceFromLocation(CLLocation(latitude: likelihood.place.coordinate.latitude, longitude: likelihood.place.coordinate.longitude)) < accuracy){
                        
                        let place = likelihood.place
                        var query = PFQuery(className: "Posts")
                        query.whereKey("googlePlacesId", equalTo: place.placeID)
                        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
                            if(error != nil){
                                print(error)
                            }
                            else{
                                if(results != nil){
                                    var cds = ContextDataSource(results: results!)
                                    cds.viewController = self
                                    let context = Context()
                                    context.title = place.name
                                    if index == 0{
                                        context.subtitle = "Because you're at"
                                    }
                                    else{
                                        context.subtitle = "Because you're near"
                                    }
                                    cds.context = context
                                    self.contextDataSources.append(cds)
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        })
        
        //date view controller
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        let seconds = components.second
        
        var current_time = hour * 60 * 60 + minutes * 60 + seconds
        var query = PFQuery(className: "Time")
        query.whereKey("start_time", lessThan: current_time)
        query.whereKey("end_time", greaterThan: current_time)
        
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            if(error != nil){
                print(error)
            }
            else{
                if let results = results{
                    for result in results{
                        var obj = result as! PFObject
                        var new_query = PFQuery(className: "Posts")
                        new_query.whereKey("timeId", equalTo: obj.objectId!)
                        new_query.findObjectsInBackgroundWithBlock({ (posts:[AnyObject]?, error:NSError?) -> Void in
                            var cds = ContextDataSource(results: posts!)
                            cds.viewController = self
                            var context = Context()
                            context.title = obj.objectForKey("title") as? String
                            context.subtitle = "Because it is"
                            cds.context = context
                            self.contextDataSources.append(cds)
                            self.collectionView.reloadData()
                        })
                    }
                }
            }
        }

        //Old Parse query
//        var query = PFQuery(className: "Post")
        var point = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        query.whereKey("location", nearGeoPoint: point, withinMiles:1.0)
//        
//        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
//            if(error != nil){
//                print(error)
//            }
//            else{
//                if(results != nil){
//                    self.searchResults = results as? [PFObject]
//                }
//            }
//            self.collectionView.reloadData()
//        }
        
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("contextCardCell", forIndexPath: indexPath) as! contextCardCell
            var ds = contextDataSources[indexPath.row]
            cell.collectionView.dataSource = ds
            cell.collectionView.delegate = ds
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
        var newLocation = locations[0] as! CLLocation
        
        if(newLocation.distanceFromLocation(oldLocation) > 100){
            oldLocation = newLocation
            queryObjects(newLocation)
            let location = self.manager.location
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
                var search = PFObject(className: "Search")
                search.setObject(self.searchTextField.text, forKey: "searchValue")
                search.setObject(PFUser.currentUser()!, forKey: "user")
                var geoPoint = PFGeoPoint(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude)
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
            self.searchTextField.resignFirstResponder()
            var destVC = segue.destinationViewController as! SearchWebViewController
            destVC.query = self.searchTextField.text
        }
        else if(segue.identifier == "suggestedSearched"){
            var destVC = segue.destinationViewController as! SearchWebViewController
            let cell = sender as! searchesCell
            destVC.query = cell.searchLabel.text
        }
        else if(segue.identifier == "feedToCreatePost"){
            let destVC = segue.destinationViewController as! CreatePostViewController
            destVC.ppDataSource.placesList = self.likelihoods
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.performSegueWithIdentifier("searched", sender: self)
        return true
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

