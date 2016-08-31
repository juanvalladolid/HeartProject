//
//  HealthClientType.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/05/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import HealthKit

protocol HealthClientType {
    var healthStore: HKHealthStore? { get set }
}

extension UIViewController {
    
    func injectHealthStore(healthStore: HKHealthStore) {
        if var client = self as? HealthClientType {
            client.healthStore = healthStore
        }
        
        for childViewController in childViewControllers {
            childViewController.injectHealthStore(healthStore)
        }
    }
}