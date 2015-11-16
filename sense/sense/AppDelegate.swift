//
//  AppDelegate.swift
//  sense
//
//  Created by Aaron Loh on 3/10/15.
//  Copyright © 2015 Aaron Loh. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let appLocationManager = CLLocationManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize Parse.
        Parse.setApplicationId("uG9WYyFl6dfBHXoHc7arEN5lFYEzz59BK03AxB4t",
            clientKey: "uX6ZXOLDfcggZhIpKreVqojACXbq470vZ2J8p49i")
        
        //MARK: notifications code
        var categories = Set<UIUserNotificationCategory>()
        
        let investigateHotspotAction = UIMutableUserNotificationAction()
        investigateHotspotAction.title = NSLocalizedString("Investigate", comment: "investigate event")
        investigateHotspotAction.identifier = "INVESTIGATE_EVENT_IDENTIFIER"
        investigateHotspotAction.activationMode = UIUserNotificationActivationMode.Foreground
        investigateHotspotAction.authenticationRequired = false
        
        let investigateCategory = UIMutableUserNotificationCategory()
        investigateCategory.setActions([investigateHotspotAction],
            forContext: UIUserNotificationActionContext.Default)
        investigateCategory.identifier = "INVESTIGATE_CATEGORY"
        
        categories.insert(investigateCategory)
    
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories))  // types are UIUserNotificationType members
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        appLocationManager.delegate = self
        appLocationManager.requestAlwaysAuthorization()
        
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
    
    func triggerUserEnteredRegionNotification(region: CLRegion!) {
        //get region data
        print("entered region")
        var monitoredHotspotDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedHotspotsRegionKey) ?? [:]
        let hotspot = monitoredHotspotDictionary[region.identifier]
        guard let tag = hotspot!["tag"] as! String? else {return}
        let identifier = hotspot!["id"] as! String
        
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active {
            if let viewController = window?.rootViewController {
                let alert = UIAlertController(title: "\(tag) detected", message: "\(identifier)", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alert.addAction(action)
                viewController.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = "\(tag) detected with id \(identifier)"
            notification.soundName = "Default"
            notification.category = "INVESTIGATE_CATEGORY"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    //MARK: Location Manager Delegate Methods for region monitoring
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            triggerUserEnteredRegionNotification(region)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("user did exit region")
        }
    }

    
}

