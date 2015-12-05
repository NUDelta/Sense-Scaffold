//
//  ViewController.swift
//  sense
//
//  Created by Aaron Loh on 3/10/15.
//  Copyright © 2015 Aaron Loh. All rights reserved.
//

import UIKit
import WatchConnectivity
import Parse
import CoreLocation
import Foundation

let savedHotspotsRegionKey = "savedMonitoredHotspots" // for saving the fetched locations to NSUserDefaults

class ViewController: UIViewController,WCSessionDelegate,CLLocationManagerDelegate {
    
    let watchSession = WCSession.defaultSession()
    let appLocManager = CLLocationManager()
    
    @IBOutlet weak var debugText: UITextView!
    
    @IBAction func clearGeofences(sender: AnyObject) {
        print("THIS GOT CALLED")
        stopMonitoringAllHotspots()
    }
    
    @IBAction func printMonitoredRegions(sender: AnyObject) {
        let monitoredHotspotDictionary = NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.dictionaryForKey(savedHotspotsRegionKey) ?? [:]
        //let monitoredHotspotDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedHotspotsRegionKey) ?? [:]
        debugText.text = debugText.text + "\(monitoredHotspotDictionary)"
        for region in appLocManager.monitoredRegions {
            debugText.text = debugText.text + " " + region.identifier
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view controller on iPhone")
        self.debugText.text = self.debugText.text + "started App view did load on iPhone"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    /** From example app:
    Sets the delegates and activate the `WCSession`.
    
    The `WCSession` needs to be activated in the init methods so that when the
    app is launched into the background when it wasn't previously running, the
    session can still be activated allowing communication between the watch and
    the phone. Activating the session in the `viewDidLoad()` method wont suffice
    since the `viewDidLoad()` method will not be called if the app is launched
    into the background.
    */
    func commonInit() {
        
        // Initialize the `WCSession` and the `CLLocationManager`.
        watchSession.delegate = self
        watchSession.activateSession()
        
        appLocManager.delegate = self
        appLocManager.startMonitoringSignificantLocationChanges()

    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        guard let command = message["command"] as! String! else {return}
        
        //Parse code: need to port over to iPhone side
        switch command{
            case "reportLocation":
                guard let messageLat = message["latitude"] as! Double? else { return }
                guard let messageLong = message["longitude"] as! Double? else { return }
                let geoPoint = PFGeoPoint(latitude: messageLat, longitude: messageLong)
                
                let hotspot = PFObject(className: "Hotspot")
                hotspot.setObject(geoPoint, forKey: "location")
                hotspot["tag"] = message["tag"]
                hotspot.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        
                        // The object has been saved.
                        replyHandler([
                            "objectID": hotspot.objectId as! AnyObject
                        ])
                    } else {
                        // There was a problem, check error.description
                    }
                }

            
            case "searchLocations":
                let query = PFQuery(className: "Hotspot")
                PFGeoPoint.geoPointForCurrentLocationInBackground {
                    (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                    if error == nil {
                        
                        query.whereKey("location", nearGeoPoint: geoPoint!, withinKilometers: 1)
                        let timeInterval = NSDate(timeIntervalSinceNow: -3600)
                        query.whereKey("createdAt", greaterThan: timeInterval)
                        query.limit = 10;
                        query.findObjectsInBackgroundWithBlock {
                            (objects: [PFObject]?, error: NSError?) -> Void in
                            if error == nil {
                                // The find succeeded.
                                print("Successfully retrieved \(objects!.count) scores.")
                                var geoPointDict = [String:AnyObject]()
                                geoPointDict[String(0)] = objects!.count
                                if (objects!.count == 0) {return}
                                for index in 1...objects!.count{
                                    var hotspotDict = [String:AnyObject]()
                                    let entry = objects![index-1]
                                    let location = entry["location"]
                                    hotspotDict["latitude"] = location.latitude
                                    hotspotDict["longitude"] = location.longitude
                                    hotspotDict["tag"] = entry["tag"]
                                    hotspotDict["timeCreated"] = entry.createdAt
                                    geoPointDict[String(index)] = hotspotDict
                                }
                                print(geoPointDict);
                                replyHandler(
                                    geoPointDict
                                    )
                            } else {
                                // Log details of the failure
                                print("Error: \(error!)")
                                replyHandler([
                                    "msg": "there was an error: \(error!)"
                                    ])
                            }
                        }
                    }else{
                        replyHandler([
                            "msg": "HEY ERROR\(error)"
                            ])
                    }
                    
                }
            
            
            case "updateObject":
                guard let parseObjectID = message["objectID"] as! String? else { return }
                let query = PFQuery(className:"Hotspot")
                query.getObjectInBackgroundWithId(parseObjectID) {
                    (hotspot: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let hotspot = hotspot {
                        print(hotspot)
                        print(hotspot["info"])
                        
                        var infoDict:[String:AnyObject] = hotspot["info"] as! [String : AnyObject]
                        
                        for (field, value) in message {
                            if (field == "tag"){
                                hotspot[field] = value
                            }else if (field != "objectID" && field != "command"){
                                infoDict[field] = value
                                print ("\(field) \(value)")
                            }
                        }
                        hotspot["info"] = infoDict
                        hotspot.saveInBackground()
                    }
                }
                replyHandler([
                    "received": "yes"
                ])
            
            case "fetchQuestions":
                //stopMonitoringAllHotspots()
                
                PFGeoPoint.geoPointForCurrentLocationInBackground {
                    (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                    if error == nil {
                        PFCloud.callFunctionInBackground("fetchQuestions",
                            withParameters: ["latitude" as NSObject:geoPoint?.latitude as! AnyObject, "longitude"as NSObject:geoPoint?.longitude as! AnyObject],
                            block: { reply in
                                guard let arr = (reply.0) else { return }
                                let retArr = (arr as! NSArray) as Array
                                
                                var monitoredHotspotDictionary = NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.dictionaryForKey(savedHotspotsRegionKey) ?? Dictionary()
                                //var monitoredHotspotDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedHotspotsRegionKey) ?? Dictionary()
                                
                                
                                for entry in retArr{
                                    let unwrappedEntry = entry as! Dictionary<String,AnyObject>
                                    let latitude = unwrappedEntry["latitude"] as! Double
                                    let longitude = unwrappedEntry["longitude"] as! Double
                                    let identifier = unwrappedEntry["id"] as! String
                                    let tag = unwrappedEntry["tag"] as? String ?? ""
                                    let date = unwrappedEntry["date"] as! NSDate
                                    let hotspot = Hotspot(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), tag: tag, timeCreated: date, id: identifier)
                                    print (entry)
                                    self.debugText.text = self.debugText.text + "starting to monitor " + identifier
                                    self.startMonitoringHotspot(hotspot)
                                    monitoredHotspotDictionary[identifier] = unwrappedEntry
                                    print(monitoredHotspotDictionary[identifier] as! Dictionary<String,AnyObject>)
                                }
                                
                                //NSUserDefaults.standardUserDefaults().setObject(monitoredHotspotDictionary, forKey: savedHotspotsRegionKey)
                                NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.setObject(monitoredHotspotDictionary, forKey: savedHotspotsRegionKey)
                                replyHandler(["missingInfo": arr ])
                            }
                        )
                    }else{
                        replyHandler(["msg": "Error in getting geopoint while fetching questions\(error)" ])
                    }
                }
            
            case "fetchQuestionsForInstance":
                guard let hotspotID = message["hotspotID"] as! String? else { return }
                PFCloud.callFunctionInBackground("fetchQuestionsForInstance",
                    withParameters: ["hotspotID" as NSObject:hotspotID as AnyObject],
                    block: { reply in
                        guard let arr = (reply.0) else { return }
                        let retArr = (arr as! NSArray) as Array
                        
                        var monitoredHotspotDictionary = NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.dictionaryForKey(savedHotspotsRegionKey) ?? Dictionary()
                        //var monitoredHotspotDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedHotspotsRegionKey) ?? Dictionary()
                        
                        
                        for entry in retArr{
                            let unwrappedEntry = entry as! Dictionary<String,AnyObject>
                            let latitude = unwrappedEntry["latitude"] as! Double
                            let longitude = unwrappedEntry["longitude"] as! Double
                            let identifier = unwrappedEntry["id"] as! String
                            let tag = unwrappedEntry["tag"] as? String ?? ""
                            let date = unwrappedEntry["date"] as! NSDate
                            let hotspot = Hotspot(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), tag: tag, timeCreated: date, id: identifier)
                            print (entry)
                            self.debugText.text = self.debugText.text + "starting to monitor " + identifier
                            self.startMonitoringHotspot(hotspot)
                            monitoredHotspotDictionary[identifier] = unwrappedEntry
                            print(monitoredHotspotDictionary[identifier] as! Dictionary<String,AnyObject>)
                        }
                        
                        //NSUserDefaults.standardUserDefaults().setObject(monitoredHotspotDictionary, forKey: savedHotspotsRegionKey)
                        NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.setObject(monitoredHotspotDictionary, forKey: savedHotspotsRegionKey)
                        replyHandler(["missingInfo": arr ])
                    }
                )

            
            case "printToIPhone":
                let textToPrint = message["text"] as! String
                dispatch_async(dispatch_get_main_queue(), {
                    self.debugText.text = self.debugText.text + textToPrint
                })
                replyHandler([
                    "received": "yes"
                    ])
            
            default:
                break
        }
        
        return
    }
    
    func startMonitoringHotspot(hotspot: Hotspot){
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: hotspot.location.latitude, longitude: hotspot.location.longitude), radius: 10, identifier: hotspot.id)
        print(hotspot.location.latitude)
        print(hotspot.location.longitude)
        region.notifyOnEntry = true
        appLocManager.startMonitoringForRegion(region)
    }
    
    
    func stopMonitoringHotspot(hotspot: Hotspot) {
        for region in appLocManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == hotspot.id {
                    appLocManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    
    func stopMonitoringAllHotspots() {
        for region in appLocManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                    appLocManager.stopMonitoringForRegion(circularRegion)
            }
        }
        //reset dictionary in NSUserDefaults
        NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.removeObjectForKey(savedHotspotsRegionKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(savedHotspotsRegionKey)
    }
    

    
    func getNearbyHotspots(){
        //reset everything
        //stopMonitoringAllHotspots()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                PFCloud.callFunctionInBackground("fetchQuestions",
                    withParameters: ["latitude" as NSObject:geoPoint?.latitude as! AnyObject, "longitude"as NSObject:geoPoint?.longitude as! AnyObject],
                    block: { reply in
                        guard let arr = (reply.0) else { return }
                        let retArr = (arr as! NSArray) as Array
                        
                        var monitoredHotspotDictionary = NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.dictionaryForKey(savedHotspotsRegionKey) ?? Dictionary()
                        //var monitoredHotspotDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedHotspotsRegionKey) ?? Dictionary()
                        //reset dictionary
                        //var monitoredHotspotDictionary = [String:Dictionary<String,AnyObject>]()
                        
                        for entry in retArr{
                            let unwrappedEntry = entry as! Dictionary<String,AnyObject>
                            let latitude = unwrappedEntry["latitude"] as! Double
                            let longitude = unwrappedEntry["longitude"] as! Double
                            let identifier = unwrappedEntry["id"] as! String
                            let tag = unwrappedEntry["tag"] as? String ?? ""
                            let date = unwrappedEntry["date"] as! NSDate
                            let hotspot = Hotspot(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), tag: tag, timeCreated: date, id: identifier)
                            self.debugText.text = self.debugText.text + "starting to monitor " + identifier + " in function getNearbyHotspots"
                            print (entry)
                            
                            self.startMonitoringHotspot(hotspot)
                            monitoredHotspotDictionary[identifier] = unwrappedEntry
                        }
                        monitoredHotspotDictionary["questionArr"] = arr
                        NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.setObject(monitoredHotspotDictionary, forKey: savedHotspotsRegionKey)
                        //NSUserDefaults.standardUserDefaults().setObject(monitoredHotspotDictionary, forKey: savedHotspotsRegionKey)
                    }
                )
            }else{
                print ("failed to get nearby hotspots with error \(error)")
            }
        }

    }
    
    
    //location manager delegate methods
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("location manager failed in view controller")
        debugText.text = debugText.text + "location manager failed in view controller";
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("location manager failed to monitor for region with error \(error)")
        debugText.text = debugText.text + "location manager failed to monitor for region with error \(error)";
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //getNearbyHotspots()
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        debugText.text = debugText.text + " entered Region "
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        debugText.text = debugText.text + " exited Region "
    }

    @IBOutlet weak var objectIDTextField: UITextField!
    
    @IBAction func fakeNotif(sender: AnyObject) {
        //debugText.text = debugText.text + objectIDTextField.text!
        fakeTriggerUserEnteredRegionNotification(objectIDTextField.text!)
    }
    
    //fake notification method
    func fakeTriggerUserEnteredRegionNotification(regionId: String) {
        var monitoredHotspotDictionary = NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.dictionaryForKey(savedHotspotsRegionKey) ?? [:]
        let hotspotDict = monitoredHotspotDictionary[regionId]
        debugText.text = debugText.text + "\(hotspotDict)" + "here"
        //guard let tag = hotspotDict!["tag"] as! String? else {return}
        let tag = hotspotDict!["tag"] as! String
        let identifier = hotspotDict!["id"] as! String
        
        // Otherwise present a local notification
        let notification = UILocalNotification()
        notification.alertBody = "\(tag) detected with id \(identifier)"
        notification.soundName = "Default"
        notification.category = "INVESTIGATE_CATEGORY"
        notification.userInfo = hotspotDict as? Dictionary
        notification.fireDate = NSDate().dateByAddingTimeInterval(5)
        debugText.text = debugText.text + regionId
    
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}




