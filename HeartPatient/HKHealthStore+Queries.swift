//
//  HKHealthStore+Queries.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/05/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import HealthKit

extension HKHealthStore {
    /// Asynchronously fetches the most recent quantity sample of a specified type.
    func mostRecentQauntitySampleOfType(quantityType: HKQuantityType, predicate: NSPredicate? = nil, completion: (HKQuantity?, NSError?) -> Void) {
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 1, sortDescriptors: [timeSortDescriptor]) { _, samples, error in
            if let firstSample = samples?.first as? HKQuantitySample {
                completion(firstSample.quantity, nil)
            }
            else {
                completion(nil, error)
            }
        }
        
        executeQuery(query)
    }
    
    
    
}