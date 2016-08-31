//
//  HeartRateGraphDataSource.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 01/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import ResearchKit

class HeartRateGraphDataSource: NSObject, ORKGraphChartViewDataSource {
    // MARK: Properties
    
    var heartRateChartXaxis = [NSDate]()
    
    
    func setHeartRateChartXAxis (titles : [NSDate])
    {
        self.heartRateChartXaxis = titles;
        
    }
    
    var maxValue : CGFloat = 0.0
    var minValue : CGFloat = 0.0
    
    var plotPoints =
        [
            [
                ORKRangedPoint(minimumValue: 0, maximumValue: 2),
                ORKRangedPoint(minimumValue: 1, maximumValue: 4),
                ORKRangedPoint(minimumValue: 2, maximumValue: 6),
                ORKRangedPoint(minimumValue: 3, maximumValue: 8),
                ORKRangedPoint(minimumValue: 5, maximumValue: 10),
                ORKRangedPoint(minimumValue: 8, maximumValue: 13),
            ]
    ]
    
    // MARK: ORKGraphChartViewDataSource
    
    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
    
    func maximumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return self.maxValue + 40.0
    }
    
    func minimumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return self.minValue
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        
        // Format date on X axis
        var xAxis : String = ""
        var firstDayMonthIndex  = 0
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Year, .Month], fromDate: NSDate())
        let startOfMonth = calendar.dateFromComponents(components)!
        let startOfMonthString = dateFormatter.stringFromDate(startOfMonth)
        //print(dateFormatter.stringFromDate(startOfMonth), startOfMonth, NSDate())
        
        // Compares the STRING DATES of first date of a month with the array of dates created to populate blood pressures
        for i in 0 ..< heartRateChartXaxis.count {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateBloodPressureString = dateFormatter.stringFromDate(heartRateChartXaxis[i])
            let dateBloodPressureStringShorter = dateBloodPressureString.substringWithRange(dateBloodPressureString.startIndex.advancedBy(0) ..< dateBloodPressureString.startIndex.advancedBy(10))
            
            if startOfMonthString == dateBloodPressureStringShorter {
                firstDayMonthIndex = i
                //print(i, startOfMonthString, dateBloodPressureShorter)
                
            }
        }
        
        if (self.heartRateChartXaxis.count > 0)
        {
            let count = pointIndex
            let date = heartRateChartXaxis[count]
            let dateFormatter = NSDateFormatter()
            //print("dates: ", date)
            
            if count == 0 {
                
                //dateFormatter.dateFormat = "EE" // weekday superset of OP's format http://nsdateformatter.com/
                dateFormatter.dateFormat = "MMM dd" // month and day superset of OP's format
                xAxis = dateFormatter.stringFromDate(date)
                
            }

            else {
                dateFormatter.dateFormat = "d"
                xAxis = dateFormatter.stringFromDate(date)
            }
            
            if count == firstDayMonthIndex {
                dateFormatter.dateFormat = "MMM d" // month and day superset of OP's format
                xAxis = dateFormatter.stringFromDate(date)
            }
            
            
        }
        return xAxis
    }

    
}
