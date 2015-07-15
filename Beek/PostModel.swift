//
//  PostModel.swift
//  Beek
//
//  Created by Mayank Jain on 7/11/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import CoreLocation
import Parse

class PostModel{
    var title : String!
    var body : String!
    var url : String!
    var authorID : String!
    var location : CLLocationCoordinate2D!
    var image : UIImage?
    
    var parseObj : PFObject!
    
    init(title:String, body:String, url:String, authorID:String, location:CLLocationCoordinate2D){
        self.title = title
        self.body = body
        self.url = url
        self.authorID = authorID
        self.location = location
        self.parseObj = PFObject(className: "Post")
    }
    
    init(object: PFObject){
        self.title = object.objectForKey("title") as? String
        self.body = object.objectForKey("body") as? String
        self.url = object.objectForKey("url") as? String
        self.authorID = object.objectForKey("authorID") as? String
        var geoPoint = object.objectForKey("location") as? PFGeoPoint
        self.location = CLLocationCoordinate2D(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude)
        
        self.parseObj = object
    }
    
    func saveInBackground(){
        updateParseObject()
        parseObj.saveInBackgroundWithBlock(nil)
    }
    
    func updateParseObject(){
        parseObj.setObject(title!, forKey: "title")
        parseObj.setObject(body!, forKey: "body")
        parseObj.setObject(url!, forKey: "url")
        
        var user = PFUser()
        user.objectId = authorID
        parseObj.setObject(user, forKey: "author")
        
        var geoPoint = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        parseObj.setObject(geoPoint, forKey: "location")
        
        if let objImage = image{
            var jpegImage = UIImageJPEGRepresentation(objImage, 1.0)
            let file = PFFile(name: "image.jpg", data: jpegImage)
            parseObj.setObject(file, forKey: "image")
        }
    }
    
}