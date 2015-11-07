//
//  ComplicationController.swift
//  sense WatchKit Extension
//
//  Created by Aaron Loh on 3/10/15.
//  Copyright © 2015 Aaron Loh. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward, .Backward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
//        // Call the handler with the current timeline entry
//        let ComplicationCurrentEntry = "ComplicationCurrentEntry"
//        let ComplicationTextData = "ComplicationTextData"
//        let ComplicationShortTextData = "ComplicationShortTextData"
//        
//
//        // Get the complication data from the extension delegate.
//        let myDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
//        var data : Dictionary = myDelegate.myComplicationData[ComplicationCurrentEntry]!
//        
//        var entry : CLKComplicationTimelineEntry?
//        let now = NSDate()
//        
//        // Create the template and timeline entry.
//        if complication.family == .ModularSmall {
//            let longText = data[ComplicationTextData]
//            let shortText = data[ComplicationShortTextData]
//            
//            let textTemplate = CLKComplicationTemplateModularSmallSimpleText()
//            textTemplate.textProvider = CLKSimpleTextProvider(text: longText, shortText: shortText)
//            
//            // Create the entry.
//            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
//        }
//        else {
//            // ...configure entries for other complication families.
//        }
//        
        // Pass the timeline entry back to ClockKit.
        //handler(entry)
        
        let template = CLKComplicationTemplateModularSmallRingText()
        template.textProvider = CLKSimpleTextProvider(text: "◼︎")
        template.fillFraction = 2.00
        template.ringStyle = CLKComplicationRingStyle.Closed
        let now = NSDate()
        let entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        
        handler(entry)

    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(nil);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        let template = CLKComplicationTemplateModularSmallRingText()
        //let template2 = CLKComplicationTemplateModularSmallSimpleImage();
        //template2.imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteral: "deltasymbol.png"))
        template.textProvider = CLKSimpleTextProvider(text: "◼︎")
        template.fillFraction = 2.00
        template.ringStyle = CLKComplicationRingStyle.Closed
        
        handler(template)
    }
    
}
