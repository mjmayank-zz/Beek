//
//  AppDelegate.swift
//  Beek
//
//  Created by Mayank Jain on 7/9/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import UIKit
import QuadratTouch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    let locationManager = LocationManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Foursquare API Integration
        let client = Client(clientID:       "I2J4JN5GIOMDNSFP02H3CWYTQ0L0CXMRTVRXSWVR3XRZCCJ2",
            clientSecret:   "H5MDABPQUUGLG25LEDYXH3JKBYIVGQMHALQ1VUAA2HKHSCLC",
            redirectURL:    "testapp123://foursquare")
        var configuration = Configuration(client:client)
        Session.setupSharedSessionWithConfiguration(configuration)
        
        //GoogleMaps API Integratrion
        GMSServices.provideAPIKey("AIzaSyBkIJEcKGgna1xVqCKKhdkifo91TvjYI18")
        
        //LocationKit Integration
//        let locationKit = LocationKit.sharedInstance()
//        locationKit.startWithApiToken("0961455db144c71c", andDelegate: self.locationManager)
        
        //Parse API Integration
        Parse.setApplicationId("75sRxIv4FG78YmOFLZuMn5hycdWfyPELYi1NF4Va", clientKey: "fJdZ5DWAVD5CVtPeGlUU1dlvW78dVRhwhkRVthcB")
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 17.0/255, green: 119.0/255, blue: 170.0/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var storyboardId = (PFUser.currentUser() != nil) ? "feedNavigationController" : "loginViewController";
        var viewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier(storyboardId) as! UIViewController
        
        self.window!.rootViewController = viewController;
        self.window!.makeKeyAndVisible();
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

