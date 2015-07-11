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

class CreatePostViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate{
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
        self.mapView.delegate = self
        
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
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = self.mapView.userLocation.coordinate
//            annotation.title = "Title" //You can set the subtitle too
            self.mapView.addAnnotation(annotation)
            
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
        var location = manager.location
        var object = PostModel(title: title, body: body, url: url, authorID: PFUser.currentUser()!.objectId!, location: location)
        object.saveInBackground()
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
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var pin = self.mapView.dequeueReusableAnnotationViewWithIdentifier("myPin")
        if(pin == nil) {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        } else {
            pin.annotation = annotation;
        }
        
        var newPin = pin as! MKPinAnnotationView
        
        newPin.animatesDrop = true;
        newPin.draggable = true;
        
        return newPin;
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if (newState == MKAnnotationViewDragState.Ending)
        {
            var droppedAt = view.annotation.coordinate
            print("Pin dropped at %f,%f")
            print(droppedAt.latitude)
            print(droppedAt.longitude);
        }
    }
    
}