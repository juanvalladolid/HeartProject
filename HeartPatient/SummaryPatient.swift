//
//  Patient.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import Foundation

class SummaryPatient: NSObject {
    
    var uid: String = ""
    
    var userName: String = "user"
    
    var weight: String = ""
    var weightValue: Float = 0.0
    var weightAdvice: String = ""
    
    var bloodPressure: String = ""
    var bloodPressureValue: Float = 0.0
    var bloodPressureAdvice: String = ""
    
    var heartRate: String = ""
    var heartRateValue: Float = 0.0
    var heartRateAdvice: String = ""
    
    var symptom1Advice: String = ""
    var symptomSweeling: String = ""
    var symptom1TodayAndYesterday: String = ""
    var symptomSleep:String  = ""
    
    var date: String = ""
    
    var count: Int = 0
}