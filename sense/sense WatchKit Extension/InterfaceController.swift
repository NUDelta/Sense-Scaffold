//
//  InterfaceController.swift
//  sense WatchKit Extension
//
//  Created by Aaron Loh on 3/10/15.
//  Copyright © 2015 Aaron Loh. All rights reserved.
//

import WatchKit
import Foundation
//import Parse
//import Bolts
import WatchConnectivity

let savedHotspotsRegionKey = "savedMonitoredHotspots" // for saving the fetched locations to NSUserDefaults

class InterfaceController: WKInterfaceController,CLLocationManagerDelegate,WCSessionDelegate {
    
    /// Location manager to request authorization and location updates.
    let locManager = CLLocationManager()
    
    /// Flag indicating whether the manager is requesting the user's location.
    var isRequestingLocation = false
    var isSearchingLocations = false
    var currentLocation:CLLocationCoordinate2D? = nil
    var mostRecentLocationObjectID = ""
    var mostRecentTag=""
    // session for communicating with iPhone
    let watchSession = WCSession.defaultSession()
    
    @IBOutlet var numHotspotsLabel: WKInterfaceLabel!
    
    @IBAction func reportFood() {
       /* if(mostRecentLocationObjectID != ""){
            let message = ["command":"updateObject", "objectID": mostRecentLocationObjectID, "tag": "food"]
            print(message)
            watchSession.sendMessage(message, replyHandler: {replyDictionary in
                print("object updated")
                self.mostRecentLocationObjectID=""
                }, errorHandler: {error in
                    print("error in updating object")})
        }else{
        }*/
        mostRecentTag = "food"
        reportLocation()
    }
    
    @IBAction func reportInfoSession() {
        mostRecentTag = "infosession"
        reportLocation()
    }
    
    @IBAction func reportMusic() {
        mostRecentTag = "music"
        reportLocation()
    }
    
    @IBAction func searchLocations() {
        if (isSearchingLocations) {
            return
        }
        if (currentLocation != nil){
            requestiPhoneSearch(currentLocation!)
        }else{
            let authorizationStatus = CLLocationManager.authorizationStatus()
            
            switch authorizationStatus{
            case .NotDetermined:
                locManager.requestWhenInUseAuthorization()
                print("Not Determined")
            case .AuthorizedWhenInUse:
                isRequestingLocation = true
                locManager.requestLocation()
                print("requesting location")
            case .AuthorizedAlways:
                locManager.requestLocation()
            default:
                break
            }
        }
    }
    
    @IBAction func tempFetchQn() {
        fetchQuestions();
    }
    
    @IBAction func tmpFetchInstance() {
        fetchQuestionsForInstance("wRObQ6T9eq");
    }

    func reportLocation() {
        printToIPhone("reporting location from watch")
        //to prevent multiple reports of location
        if (isRequestingLocation) {
            locManager.stopUpdatingLocation()
            isRequestingLocation = false
            return
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        print(authorizationStatus)
        print("isRequestingLocation: \(isRequestingLocation)")
        
        switch authorizationStatus{
        case .NotDetermined:
            locManager.requestWhenInUseAuthorization()
            print("Not Determined")
        case .AuthorizedWhenInUse:
            isRequestingLocation = true
            locManager.requestLocation()
            print("requesting location")
        case .AuthorizedAlways:
            isRequestingLocation = true
            locManager.requestLocation()
        default:
            break
        }
    }
    
    // MARK: Initialization
    
    override func awakeWithContext(context: AnyObject?) {
        
        super.awakeWithContext(context)
        locManager.delegate = self
        watchSession.delegate=self
        watchSession.activateSession()
        printToIPhone("awake with context method called")
        // Configure interface objects here.
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        super.willActivate()
        locManager.delegate = self
        watchSession.delegate=self
        watchSession.activateSession()
        //reset variables:
        mostRecentTag = ""
        isRequestingLocation = false
        isSearchingLocations = false
        //reportLocation()
        fetchQuestionsInBackground();
        printToIPhone("will activate method called")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    //Mark: Communicating with iPhone
    func sendLocationToiPhone(location: CLLocationCoordinate2D, tag:String){
        let message = ["command":"reportLocation", "latitude": location.latitude, "longitude":location.longitude, "tag":tag]
        print(message)
        watchSession.sendMessage(message as! [String : AnyObject], replyHandler: {replyDictionary in
                print("reply handler called")
                guard let entryID = replyDictionary["objectID"] as? String else {return}
                self.fetchQuestionsForInstance(entryID)
                print(entryID)
                self.mostRecentLocationObjectID = entryID
            }, errorHandler: {error in
                print("error in sending location")})
    }
    
    func requestiPhoneSearch(location: CLLocationCoordinate2D){
        let message = ["command": "searchLocations"]
        print(message)
        watchSession.sendMessage(message, replyHandler: {replyDictionary in
                print("reply handler called for request")
                print(replyDictionary)
                guard let numHotspots = replyDictionary["0"] as? Int else {return}
                print(numHotspots)
                self.numHotspotsLabel.setText("\(numHotspots) hotspots")
            }, errorHandler: {error in
                print("error in requesting location \(error)")})
    }
    
    func fetchQuestions(){
        let message = ["command": "fetchQuestions"]
        print(message)
        watchSession.sendMessage(message, replyHandler: {replyDictionary in
            print(replyDictionary)
            guard let questionArray = replyDictionary["missingInfo"] as! Array<Dictionary<String,AnyObject>>? else {return}
            print(questionArray)
            //print((questionArray[0]["duration"])!)
            self.pushControllerWithName("getInfoController", context: questionArray)
            print("reply handler called for fetch questions")
            }, errorHandler: {error in
                print("error in fetching questions \(error)")})
    }
    
    func fetchQuestionsInBackground(){
        let message = ["command": "fetchQuestions"]
        print(message)
        watchSession.sendMessage(message, replyHandler: {replyDictionary in
            print(replyDictionary)
            print("reply handler called for fetch questions in background")
            }, errorHandler: {error in
                print("error in fetching questions \(error)")})
    }
    
    func fetchQuestionsForInstance(hotspotID: String){
        let message = ["command": "fetchQuestionsForInstance", "hotspotID": hotspotID]
        print(message)
        watchSession.sendMessage(message, replyHandler: {replyDictionary in
            print(replyDictionary)
            guard let questionArray = replyDictionary["missingInfo"] as! Array<Dictionary<String,AnyObject>>? else {return}
            print(questionArray)
            self.presentControllerWithName("getInfoController", context: questionArray)
            print("reply handler called for fetch questions for instance")
            }, errorHandler: {error in
                print("error in fetching questions for instance\(error)")})
    }
    
    func printToIPhone(text: String){
        let message = ["command": "printToIPhone", "text": text]
        watchSession.sendMessage(message, replyHandler: {replyDictionary in
            print(replyDictionary)
            }, errorHandler: {error in
                print("error in printing text \(error)")})
    }
    
    //MARK: Location Manager Delegate methods:
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty{
            return
        }
        //checking to see if this was from the last button press or not, avoid repeat entries.. LOGIC NOT CLEAR, CHECK.
        if(!isRequestingLocation){
            return;
        }
        dispatch_async(dispatch_get_main_queue()){
        
            let mostRecentLocationCoordinate = locations.last!.coordinate

            //mapView code, just keeping it here in case it comes up later
            /*
            let updatedSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let updatedAreaRegion = MKCoordinateRegion(center: mostRecentLocationCoordinate, span: updatedSpan)
            
            self.mapView.removeAllAnnotations()
            self.mapView.addAnnotation(mostRecentLocationCoordinate, withPinColor: .Purple)
            self.mapView.setRegion(updatedAreaRegion)*/
            
            self.isRequestingLocation = false
            print(mostRecentLocationCoordinate)
            self.sendLocationToiPhone(mostRecentLocationCoordinate,tag: self.mostRecentTag)
            self.currentLocation = mostRecentLocationCoordinate
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        dispatch_async(dispatch_get_main_queue()){
            guard self.isRequestingLocation else { return }
            
            switch status{
            case .AuthorizedWhenInUse:
                self.locManager.requestLocation()
                print("changed auth")
            default:
                self.isRequestingLocation = false
                break
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            self.isRequestingLocation = false
            print(error)
        }
    }
    
    //MARK: handle notifications method
    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        switch(identifier!){
        case "INVESTIGATE_EVENT_IDENTIFIER":
            //print("triggered watch notification with investigate action")
            
            let hotspotID = localNotification.userInfo!["id"] as! String
            printToIPhone("handle action with identifier with \(hotspotID)")
            
            //watchSession.delegate=self
            //watchSession.activateSession()
            //fetchQuestionsForInstance(hotspotID)
            
            presentControllerWithName("getInfoController", context: [localNotification.userInfo!])
            //printToIPhone("handling notification for \(hotspotID)")
            //fetchQuestionsForInstance(hotspotID)
            /*
            var monitoredHotspotDictionary = NSUserDefaults.init(suiteName: "group.hotspotDictionary")?.dictionaryForKey(savedHotspotsRegionKey) ?? [:]
            printToIPhone("handling notification from watch!!")
            printToIPhone("handling notification for \(hotspotID)")
            printToIPhone("\(monitoredHotspotDictionary)")
                
            guard let questionArray = monitoredHotspotDictionary[hotspotID] as! Dictionary<String,AnyObject>? else {printToIPhone("could not cast questionArray for \(hotspotID)"); return;}
            //let questionArray = monitoredHotspotDictionary[hotspotID] as! Dictionary<String,AnyObject>
            //print(questionArray)*/

            break
        default:
            break
        }
    }
    

}
