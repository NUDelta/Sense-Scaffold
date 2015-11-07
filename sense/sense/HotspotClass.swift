//
//  HotspotClass.swift
//  sense
//
//  Created by Aaron Loh on 12/10/15.
//  Copyright © 2015 Aaron Loh. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Hotspot {
    var location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var tag:String = ""
    var timeCreated:NSDate = NSDate()
    var id:String = ""
    
    init(location: CLLocationCoordinate2D, tag: String, timeCreated: NSDate, id: String){
        self.location = location
        self.tag = tag
        self.timeCreated = timeCreated
        self.id = id
    }
}




