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
    
    var postURL : String?
    let manager = CLLocationManager()
    
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var bodyPlaceholderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.userLocation.addObserver(self, forKeyPath: "location", options: (NSKeyValueObservingOptions.New|NSKeyValueObservingOptions.Old), context: nil)
        self.mapView.delegate = self
        
        self.bodyTextView.delegate = self
        
        self.titleTextField.becomeFirstResponder()
        
        if let url = postURL{
            self.urlTextField.text = url
        }
        var leftConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: CGFloat(1.0), constant: CGFloat(0))
        self.view.addConstraint(leftConstraint)
        
        var rightConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: CGFloat(1.0), constant: CGFloat(0))
        self.view.addConstraint(rightConstraint)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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
//            self.mapView.addAnnotation(annotation)
            
            self.mapView.userLocation.removeObserver(self, forKeyPath: "location")
        }
    }
    
    func keyboardWillShow(notification: NSNotification){
        var info : NSDictionary = notification.userInfo!
        var kbRect = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue()
        
        kbRect = self.view.convertRect(kbRect!, fromView: nil)
        
        var contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect!.size.height, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        var aRect = self.view.frame
        aRect.size.height -= kbRect!.size.height;
//        if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
//            [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
//        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        var contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
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

class MyAnnotation : NSObject{
    var coordinate : CLLocationCoordinate2D!
    
    func initWithCoordinate(coord : CLLocationCoordinate2D) -> MyAnnotation {
        coordinate=coord
        return self
    }
    
    func coord() -> CLLocationCoordinate2D
    {
    return coordinate;
    }
    
    func setCoordinate(newCoordinate : CLLocationCoordinate2D) {
        coordinate = newCoordinate;
    }
    
}