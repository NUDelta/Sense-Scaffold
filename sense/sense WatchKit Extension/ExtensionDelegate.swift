//
//  ExtensionDelegate.swift
//  sense WatchKit Extension
//
//  Created by Aaron Loh on 3/10/15.
//  Copyright © 2015 Aaron Loh. All rights reserved.
//

import WatchKit
import Foundation

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    /*
    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        switch(identifier!){
        case "INVESTIGATE_EVENT_IDENTIFIER":
            print("triggered watch notification with investigate action")
            //pushControllerWithName("getInfoController", context: [])
            break
        default:
            break
        }
    }
    */
}
