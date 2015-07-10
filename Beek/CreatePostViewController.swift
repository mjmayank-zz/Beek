//
//  CreatePostViewController.swift
//  Beek
//
//  Created by Mayank Jain on 7/9/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Parse

class CreatePostViewController: UIViewController, UITextViewDelegate{
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var urlTextField: UITextField!
//    @IBOutlet var scrollView: UIScrollView!
    let manager = CLLocationManager()

    @IBOutlet var bodyPlaceholderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.userLocation.addObserver(self, forKeyPath: "location", options: (NSKeyValueObservingOptions.New|NSKeyValueObservingOptions.Old), context: nil)
        
        self.bodyTextView.delegate = self
        
        self.titleTextField.isFirstResponder()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if self.mapView.showsUserLocation{
            var region = MKCoordinateRegion()
            region.center = self.mapView.userLocation.coordinate;
            
            var span = MKCoordinateSpan()
            span.latitudeDelta  = 0.05 // Change these values to change the zoom
            span.longitudeDelta = 0.05
            region.span = span;
            
            self.mapView.setRegion(region, animated: true)
            self.mapView.userLocation.removeObserver(self, forKeyPath: "location")
        }
    }
    
    
    deinit{
        self.mapView.removeFromSuperview()
        self.mapView = nil
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        var body = bodyTextView.text
        var title = titleTextField.text
        var url = urlTextField.text
        var point = PFGeoPoint(latitude:manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude)
        var object = PFObject(className: "Post")
        if(url != ""){
            object.setValue(url, forKey: "url")
        }
        object.setObject(body, forKey: "body")
        object.setObject(title, forKey: "title")
        object.setObject(point, forKey: "location")
        object.setObject(PFUser.currentUser()!, forKey: "author")
        object.saveInBackgroundWithBlock(nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func textViewDidChange(textView: UITextView) {
        self.bodyPlaceholderLabel.hidden = textView.text != ""
    }
    
}