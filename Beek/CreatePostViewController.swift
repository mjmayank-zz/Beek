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


class CreatePostViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate{
    
    var postURL : String?
    var image : UIImage?
    let manager = CLLocationManager()
    var ppDataSource = PlacePickerDataSource()
    var timeDataSource = TimePickerDataSource()

    @IBOutlet var bodyTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var placePicker: UICollectionView!
    @IBOutlet var timePicker: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.userLocation.addObserver(self, forKeyPath: "location", options: (NSKeyValueObservingOptions.New|NSKeyValueObservingOptions.Old), context: nil)
        self.mapView.delegate = self
        
        self.placePicker.dataSource = ppDataSource
        self.placePicker.delegate = ppDataSource
        
        self.timePicker.dataSource = timeDataSource
        self.timePicker.delegate = timeDataSource
        
        self.titleTextField.becomeFirstResponder()
        
        if let url = postURL{
            self.urlTextField.text = url
        }
        
        var query = PFQuery(className: "Time")
        query.findObjectsInBackgroundWithBlock { (response:[AnyObject]?, error:NSError?) -> Void in
            if(error != nil){
                println(error)
            }
            else{
                self.timeDataSource.timeList = response as? [PFObject]
                self.timePicker.reloadData()
            }
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
            
            var annotation = MyAnnotation(coordinate: self.mapView.userLocation.coordinate)
//            annotation.coordinate = self.mapView.userLocation.coordinate
            annotation.title = "Title" //You can set the subtitle too
            self.mapView.addAnnotation(annotation)
            
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
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        var url = urlTextField.text
        var candidateURL = NSURL(string: url)
        if candidateURL != nil && url != ""{
            if(candidateURL!.scheme == nil) {
                url = "http://" + url
                candidateURL = NSURL(string: url)
            }
        }
        var body = bodyTextField.text
        var title = titleTextField.text
        let annotation : MKAnnotation = self.mapView.annotations[0] as! MKAnnotation
        var location = annotation.coordinate
        var object = PostModel(title: title, body: body, url: url, authorID: PFUser.currentUser()!.objectId!, location: location)
        if let place = self.ppDataSource.selectedPlace{
            object.placeId = place.placeID
        }
        if let time = self.timeDataSource.selectedObj{
            object.timeId = time.objectId
        }
        if let bgImage = image{
            object.image = bgImage
        }
        object.saveInBackground()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if(!annotation.isMemberOfClass(MyAnnotation)){
            return nil
        }
        
        var pin : MKPinAnnotationView!
        if(self.mapView.dequeueReusableAnnotationViewWithIdentifier("myPin") == nil) {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        } else {
            pin.annotation = annotation
        }
        
        pin.animatesDrop = true
        pin.draggable = true
        
        return pin
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

class MyAnnotation : NSObject, MKAnnotation{
    var myCoordinate : CLLocationCoordinate2D!
    var title : String?
    var subtitle : String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.myCoordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.myCoordinate = coordinate
    }
    
    var coordinate: CLLocationCoordinate2D {
        return myCoordinate
    }
    
    func setCoordinate(newCoordinate : CLLocationCoordinate2D) {
        self.myCoordinate = newCoordinate;
    }
    
}