//
//  LocationManager.swift
//  Beek
//
//  Created by Mayank Jain on 7/28/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import Parse
import GoogleMaps

class ContextManager: NSObject, LocationKitDelegate, CLLocationManagerDelegate {
    
    static let sharedInstance = ContextManager()
    var oldLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    var placesList = [AnyObject]()
    var timesList = [AnyObject]()
    let locationManager = CLLocationManager()
    var placesClient : GMSPlacesClient?
    var delegate : ContextManagerDelegate?
    
    override init(){
        super.init()
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        placesClient = GMSPlacesClient()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationKit(locationKit: LocationKit!, didUpdateLocation location: CLLocation!) {
        print("Delegate got a location: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
        locationKit.getCurrentPlaceWithHandler { (place:LKPlace!, error:NSError!) -> Void in
            if let place = place {
                print("The user is in (\(place.address.locality))", terminator: "")
            } else {
                print("Error fetching place: %@", error, terminator: "")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        
        if(newLocation.distanceFromLocation(oldLocation) > 100){
            oldLocation = newLocation
            queryObjects(newLocation)
        }
        
        if let delegate = delegate{
            delegate.locationManager(locationManager, didUpdateLocations: locations)
        }
    }
    
    func refresh(){
        queryObjects(locationManager.location)
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
            let json = JSON(data: data!)
        }
        
        task.resume()
        
        placesClient?.currentPlaceWithCallback({ (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.placesList = [AnyObject]()
            
            if let placeLicklihoodList = placeLikelihoodList {
                let likelihoods = placeLicklihoodList.likelihoods as? [GMSPlaceLikelihood]
                for likelihood in likelihoods!{
                    self.placesList.append(likelihood.place)
                }
                if let delegate = self.delegate{
                    delegate.didUpdateContext("places", withItems: self.placesList)
                }
            }
        })
        
        //date view controller
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        let seconds = components.second
        
        var current_time = hour * 60 * 60 + minutes * 60 + seconds
        var query = PFQuery(className: "Time")
        query.whereKey("start_time", lessThan: current_time)
        query.whereKey("end_time", greaterThan: current_time)
        
        query.findObjectsInBackgroundWithBlock { (results:[PFObject]?, error:NSError?) -> Void in
            if(error != nil){
                print(error, terminator: "")
            }
            else{
                if let results = results{
                    for result in results{
                        var obj = result
                        var new_query = PFQuery(className: "Posts")
                        new_query.whereKey("timeId", equalTo: obj.objectId!)
                        new_query.findObjectsInBackgroundWithBlock({ (posts:[PFObject]?, error:NSError?) -> Void in
                            if let posts = posts{
                                self.timesList = posts
                                if let delegate = self.delegate{
                                    delegate.didUpdateContext("times", withItems: self.timesList)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}

protocol ContextManagerDelegate{
    func didUpdateContext(context: String, withItems: [AnyObject])
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
}
