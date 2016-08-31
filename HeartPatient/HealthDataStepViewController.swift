//
//  HealthDataStepViewController.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/05/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import ResearchKit
import HealthKit

class HealthDataStepViewController: ORKInstructionStepViewController {
    // MARK: Properties
    
    var healthDataStep: HealthDataStep? {
        return step as? HealthDataStep
    }
    
    // MARK: ORKInstructionStepViewController
    
    override func goForward() {
        healthDataStep?.getHealthAuthorization() { succeeded, _ in
            // The second part of the guard condition allows the app to proceed on the Simulator (where health data is not available)
            guard succeeded || (TARGET_OS_SIMULATOR != 0) else { return }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                super.goForward()
            }
        }
    }
}
