//
//  HelperFunctions.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 24/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import Foundation
import UIKit

struct HelperFunctions {
    
    // Date
    
    static func convertDateToString(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    static func convertDateToShortString(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dateString = dateFormatter.stringFromDate(date)
        //let dateShort = dateString.substringWithRange(dateString.startIndex.advancedBy(0) ..< dateString.startIndex.advancedBy(10))
        
        return dateString
    }
    
    static func shortString(date: String) -> String {
        
        let dateShortString = date.substringWithRange(date.startIndex.advancedBy(0) ..< date.startIndex.advancedBy(10))
        
        return dateShortString
    }
    
    
    
    static func converStringToDateBloodPressure(date: String) -> NSDate {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dateNSDate = dateFormatter.dateFromString(date)
        
        return dateNSDate!
    }
    
    static func convertStringToDate(date: String) -> NSDate {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dateNSDate = dateFormatter.dateFromString(date)
        
        return dateNSDate!
    }
    
    static func convertDateToPythonDateString(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    
    static func daysBetweenDate(startDate: NSDate, endDate: NSDate) -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        
        return components.day
    }
    
    
    
}