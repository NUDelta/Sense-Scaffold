//
//  AnswerInterfaceController.swift
//  sense
//
//  Created by Aaron Loh on 20/10/15.
//  Copyright © 2015 Aaron Loh. All rights reserved.
//

import WatchKit
import Foundation


class AnswerInterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        guard let title = context else {return}
        print(title)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
