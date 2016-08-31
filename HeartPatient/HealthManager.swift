//
//  HealthManager.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 06/06/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import HealthKit
import Firebase
import FirebaseAuth

class HealthManager {
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    var dataService:FirebaseDataService = FirebaseDataService()

    
    var bloodPressureSamples = [BloodPressure]()
    var weightSamples = [Weight]()

    // variables for time queries 7:00 and 10:30 am
    let hourStart = 0
    let minuteStart = 0
    
    let hourStop = 23
    let minuteStop = 59
    

    
    // AUTHORIZATION TO HEALTHKIT
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!) {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = Set(
            arrayLiteral:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            
            //HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage)!,
            //HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,

            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)!
        )
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "jvalladolid.dk", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            let sampleTypeWeight = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
            let sampleTypeBloodPressure = HKQuantityType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)
            let sampleTypeHeartRate = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)

            
            if( completion != nil )
            {
                // Initiate observe query to observe for changes of sampletypes in HealthKit
                self.startObservingChanges(sampleTypeWeight, typeOfSample: "weight")
                self.startObservingChanges(sampleTypeBloodPressure, typeOfSample: "bloodpressure")
                self.startObservingChanges(sampleTypeHeartRate, typeOfSample: "heartrate")
                
                completion(success:success,error:error)
            }
        }
    }
    
    
    // ENABLE BACKGROUND DELIVERY FOR HEALTHKIT ENTRIES
    func startObservingChanges(sampleType: HKSampleType?, typeOfSample: String) {
        
        let query = HKObserverQuery(sampleType: sampleType!, predicate: nil) { query, completionHandler, error in
            
            if error != nil {
                print(error)
            } else {
                if typeOfSample == "weight" {
                    self.newWeightChangedHandler(query, completionHandler: completionHandler, error: error)
                } else if typeOfSample == "bloodpressure" {
                    self.bloodPressureChangedHandler(query, completionHandler: completionHandler, error: error)
                } else if typeOfSample == "heartrate" {
                    self.heartRateChangedHandler(query, completionHandler: completionHandler, error: error)
                }
            }
        }
        
        healthKitStore.executeQuery(query)
        healthKitStore.enableBackgroundDeliveryForType(sampleType!, frequency: .Immediate, withCompletion: {(succeed, error) in
            
            if succeed {
                print("Enabled background delivery of \(typeOfSample) changes")
            } else {
                if let theError = error {
                    print("Failed to enable background delivery of \(typeOfSample) changes")
                    print("Error = \(theError)")
                }
            }
        })
    }
    
    // NEW WEIGHT CHANGED HANDLER
    
    func newWeightChangedHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: NSError!) {
        let weightAnchor = "weightAnchor"
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        checkNewSamplesAnchor(sampleType!, anchor: getAnchor(weightAnchor)) { (results, newAnchor, error, anchorValue) -> Void in
            if( error != nil )
            {
                print("Error reading height from HealthKit Store: \(error.localizedDescription)")
                
            }
            print("- Weight Background observing")
            //print("- ANCHORS: WEIGHT, new value/ anchor value / results: ", newAnchor, anchorValue, results)

            self.saveAnchor(newAnchor!, anchorkey: weightAnchor)

            if(newAnchor != nil && newAnchor != anchorValue) {
                

                let weightOne = Weight()

                for data in results {
                    let weight = data as? HKQuantitySample
                    
                    let measurement = weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
                    let source = data.sourceRevision.source.name
                    let dateString = self.getDateFormat(data.endDate)
                    weightOne.measurement = Float(measurement)
                    weightOne.date = dateString
                    weightOne.sourceType = source
                    self.weightSamples.append(weightOne)
                }
                
                let username = self.dataService.getUserName()
                let userID = FIRAuth.auth()?.currentUser?.uid
                
                
                
                FIRDatabase.database().reference().child("user-weights").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if snapshot.exists() && results != []{
                        
                        //self.dataService.sendNewWeightToFireBase(userID!, username: username, measurement: Float(self.weightSamples[0].measurement), date: self.weightSamples[0].date, sourceType: self.weightSamples[0].sourceType)
                        self.dataService.sendNewWeightToFireBase(userID!, username: username, measurement: Float(weightOne.measurement), date: weightOne.date, sourceType: weightOne.sourceType)
                        
                        let notification = UILocalNotification()
                        notification.alertBody = "HeartPATIENT has just registered your Weight of today (\(weightOne.measurement)) kg from \(weightOne.sourceType). Well done :)"
                        notification.alertAction = "Open"
                        notification.soundName = UILocalNotificationDefaultSoundName
                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
                        
                        print("- Weight was sent in background. Value: ", weightOne.measurement)


                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                
            } else {
                print("No new Weight in background")
            }
        }
        
    }
    
    func bloodPressureChangedHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: NSError!) {
        
        let bloodPressureAnchor = "bloodpressureAnchor"
        
        let sampleType = HKQuantityType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)
        
        checkForNewSamplesBloodPressure(sampleType!, anchor: self.getAnchor(bloodPressureAnchor)) { (results, newAnchor, error, anchorValue) -> Void in
            if error != nil {
                print("Error reading blood pressure from HealthKit Store: \(error.localizedDescription)")
            }
            print("- Blood Pressure Background observing")
            //print("- ANCHOR BLOOD PRESSURE, new value/ anchor value/ results: ", newAnchor, anchorValue, results)
            if (newAnchor != nil && newAnchor != anchorValue) {
                self.saveAnchor(newAnchor!, anchorkey: bloodPressureAnchor)

                
                let systolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)
                let diastolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)
                
                for data in results {
                    let bloodPressureOne = BloodPressure()
                    let data1 = data.objectsForType(systolicType!).first as? HKQuantitySample
                    let data2 = data.objectsForType(diastolicType!).first as? HKQuantitySample
                    
                    let value1 = data1!.quantity.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                    let value2 = data2!.quantity.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                    print("- Background bp: \(value1) / \(value2)")
                    let username = self.dataService.getUserName()
                    print("- User name with new method from blood pressure", username)
                    bloodPressureOne.systolic = Float(value1)
                    bloodPressureOne.diastolic = Float(value2)
                    bloodPressureOne.date = self.getDateFormat(data1!.startDate)
                    bloodPressureOne.sourceType = String(data1!.sourceRevision.source.name)
                    self.bloodPressureSamples.append(bloodPressureOne)
                }
                
                let username = self.dataService.getUserName()
                let userID = FIRAuth.auth()?.currentUser?.uid
                
                for bps in self.bloodPressureSamples {
                    print("- The BP in background are", bps.systolic, bps.diastolic, bps.date)
                }
                // observe if data base exists with crawled values for the user
                
                FIRDatabase.database().reference().child("user-bps").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    // Get user value
                    
                    if snapshot.exists()  && results != [] {
                        
                        self.dataService.sendNewBloodPressureToFireBase(userID!, username: username, systolic: self.bloodPressureSamples[0].systolic, diastolic: self.bloodPressureSamples[0].diastolic, date: self.bloodPressureSamples[0].date, sourceType: self.bloodPressureSamples[0].sourceType)
                        
                        
                        let notification = UILocalNotification()
                        notification.alertBody = "HeartPATIENT has registered your Blood Pressure of today (\(self.bloodPressureSamples[0].systolic)/\(self.bloodPressureSamples[0].diastolic)) mmHg from \(self.bloodPressureSamples[0].sourceType). Well done :)"
                        notification.alertAction = "Open"
                        notification.soundName = UILocalNotificationDefaultSoundName
                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
                        
                        print("- Blood pressure value was sent in background, value: ", self.bloodPressureSamples[0].systolic, self.bloodPressureSamples[0].diastolic)
                    }
                    
                    
                }) { (error) in
                    print(error.localizedDescription)
                }


            } else {
                print("- No new Blood Pressures in background")
            }
        }

    }
    
    
    func heartRateChangedHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: NSError!) {
        
        // Here you need to call a function to query the weight change
        let heartRateAnchor = "heartrateAnchor"
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        
        
        checkNewSamplesAnchor(sampleType!, anchor: getAnchor(heartRateAnchor)) { (results, newAnchor, error, anchorValue) -> Void in
            if( error != nil )
            {
                print("Error reading height from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            //print("- ANCHOR HEART RATE, new value/ anchor value/ results: ", newAnchor, anchorValue, results)

            
            if(newAnchor != nil && newAnchor != anchorValue) {
                
                self.saveAnchor(newAnchor!, anchorkey: heartRateAnchor)

                let heartRateOne = HeartRate()
                for data in results {
                    let heartRate = data as? HKQuantitySample
                    
                    //let date = String(mostRecentHeartRate.endDate)
                    let measurement = Float(heartRate!.quantity.doubleValueForUnit(HKUnit(fromString: "count/s"))*60)
                    let date = data.endDate as NSDate
                    let dateString = self.getDateFormat(date)
                    
                    let source = data.sourceRevision.source.name
                    
                    heartRateOne.measurement = measurement
                    heartRateOne.date = dateString
                    heartRateOne.sourceType = source

                    print("- Heart Rate from background: ", heartRateOne.measurement, heartRateOne.date, heartRateOne.sourceType)
                }
                
                let username = self.dataService.getUserName()
                let userID = FIRAuth.auth()?.currentUser?.uid
                
                FIRDatabase.database().reference().child("user-heartrates").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    // Get user value
                    
                    if snapshot.exists()  && results != [] {
                        
                        self.dataService.sendNewHeartRateToFireBase(userID!, username: username, measurement: heartRateOne.measurement, date: heartRateOne.date, sourceType: heartRateOne.sourceType)
                        
                        
                        let notification = UILocalNotification()
                        notification.alertBody = "HeartPATIENT has registered your Heart Rate of today (\(heartRateOne.measurement)) bpm from \(heartRateOne.sourceType). Well done :)"
                        notification.alertAction = "Open"
                        notification.soundName = UILocalNotificationDefaultSoundName
                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
                        
                        print("- Heart Rate value was sent in background, value: ", heartRateOne.measurement, heartRateOne.date)
                    }
                    
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
           
            } else {
                print("- No new Heart Rates in background")
            }
            
        }

    }
    
    
    // GET NEW SAMPLES WITH ANCHOR
    
    func checkNewSamplesAnchor(sampleType:HKSampleType, anchor: HKQueryAnchor?, completion: (([HKSample]!, HKQueryAnchor!, NSError!, HKQueryAnchor!) -> Void)!) {
        
        var anchorValue: HKQueryAnchor?
        
        if(anchor != nil){
            anchorValue = anchor!
        } else {
            anchorValue = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
        }
        
        // PREDICATE
        //        let past = NSDate(timeIntervalSinceNow: -24*60*60)
        //        let now   = NSDate()
        let now = NSDate()
        let calendar2 = NSCalendar.currentCalendar()
        calendar2.timeZone = NSTimeZone.localTimeZone()
        
        let firstDate = calendar2.dateBySettingHour(hourStart, minute: minuteStart, second: 0, ofDate: now, options:  NSCalendarOptions())
        
        let lastDate = calendar2.dateBySettingHour(hourStop, minute: minuteStop, second: 0, ofDate: now, options:  NSCalendarOptions())
        
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(firstDate, endDate:lastDate, options: .None)
        
        //        print("This is firstDate \(firstDate) \nThis is lastDate \(lastDate) \nThis is now \(now)")
        //let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        let query = HKAnchoredObjectQuery(type: sampleType, predicate: mostRecentPredicate, anchor: anchorValue, limit: 5) { (HKAnchoredObjectQuery, results, deleted,
            newAnchor, error) -> Void in
            
            if error != nil {
                print(error)
                completion(nil, nil, error, nil)
                return
            }
            
            // Get the first sample
            let measurements = results! as? [HKQuantitySample]
            //print(results)
            
            if completion != nil {
                completion(measurements,newAnchor,nil,anchorValue)
            }
        }
        healthKitStore.executeQuery(query)
    }
    
    // Blood pressure new samples with anchor
    func checkForNewSamplesBloodPressure(sampleType:HKSampleType, anchor: HKQueryAnchor?, completion: (([HKCorrelation]!, HKQueryAnchor!, NSError!, HKQueryAnchor!) -> Void)!) {
        
        var anchorValue: HKQueryAnchor?
        
        if(anchor != nil) {
            anchorValue = anchor!
        } else {
            anchorValue = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
        }
        
        //        let past = NSDate.distantPast()
        
        // Query all data that is not more than 2 weeks old
        
        let now = NSDate()
        let calendar2 = NSCalendar.currentCalendar()
        calendar2.timeZone = NSTimeZone.localTimeZone()
        
        let firstDate = calendar2.dateBySettingHour(hourStart, minute: minuteStart, second: 0, ofDate: now, options:  NSCalendarOptions())
        
        let lastDate = calendar2.dateBySettingHour(hourStop, minute: minuteStop, second: 0, ofDate: now, options:  NSCalendarOptions())
        
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(firstDate, endDate:lastDate, options: .None)

        
        let query = HKAnchoredObjectQuery(type: sampleType, predicate: mostRecentPredicate, anchor: anchorValue, limit: 1) { (HKAnchoredObjectQuery, results, deleted,
            newAnchor, error) -> Void in
            
            if error != nil {
                print(error)
                completion(nil, nil, error, nil)
                return
            }
            
            // Get the first sample
            //let bloodPressure = results!.first as? HKCorrelation
            
            // Get all samples
            let bloodPressure = results! as? [HKCorrelation]
            
            if completion != nil {
                completion(bloodPressure,newAnchor,nil,anchorValue)
            }
        }
        healthKitStore.executeQuery(query)
    }

    
    // READ ALL SAMPLES
    func readAllSamples(sampleType:HKSampleType , completion: (([HKSample]!, NSError!) -> Void)!)
    {
        
        // 1. Build the Predicate: query values from a week ago
        
        let startDate = NSDate().dateByAddingTimeInterval(-360*24*60*60) as NSDate!
        
        let now = NSDate()
        //        let firstDate = NSDate.distantPast()
        //        let lastDate   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: now, options: .None)
        
        
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 0
        
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            
            if let _ = error {
                completion(nil,error)
                return;
            }
            
            // Get the first sample
            let allSamples = results! as? [HKQuantitySample]
            
            //print("most recent samples: \(mostRecentSample)")
            // Execute the completion closure
            if completion != nil {
                completion(allSamples,nil)
            }
            else {
                print("no values from healthkit")
            }
        }
        // 5. Execute the Query
        healthKitStore.executeQuery(sampleQuery)
    }
    
    
    // GET AND SAVE ANCHOR STRINGS
    

    
    func getAnchor(anchorkey: String) -> HKQueryAnchor? {
        let encoded = NSUserDefaults.standardUserDefaults().dataForKey(anchorkey)
        if(encoded == nil){
            return nil
        }
        let anchor = NSKeyedUnarchiver.unarchiveObjectWithData(encoded!) as? HKQueryAnchor
        return anchor
    }
    
    func saveAnchor(anchor : HKQueryAnchor, anchorkey: String) {
        let encoded = NSKeyedArchiver.archivedDataWithRootObject(anchor)
        NSUserDefaults.standardUserDefaults().setValue(encoded, forKey: anchorkey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    
    // DATE
    
    func getDateFormat(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }

}
