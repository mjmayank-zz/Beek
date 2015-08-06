//
//  LocationManager.swift
//  Beek
//
//  Created by Mayank Jain on 7/28/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation

class ContextManager: NSObject, LocationKitDelegate, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationManager()
    var placesList = [AnyObject]()
    var timesList = [AnyObject]()
    let manager = CLLocationManager()
    let placesClient = GMSPlacesClient()
    
    override init(){
        super.init()
        
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func locationKit(locationKit: LocationKit!, didUpdateLocation location: CLLocation!) {
        println("Delegate got a location: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
        locationKit.getCurrentPlaceWithHandler { (place:LKPlace!, error:NSError!) -> Void in
            if let place = place {
                print("The user is in (\(place.address.locality))")
            } else {
                print("Error fetching place: %@", error)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
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
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                println("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLicklihoodList = placeLikelihoodList {
                let likelihoods = placeLicklihoodList.likelihoods as? [GMSPlaceLikelihood]
                for likelihood in likelihoods!{
                    self.placesList.append(likelihood.place)
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
                            timesList = posts
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
    
}
