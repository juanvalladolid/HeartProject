//
//  BloodPressure.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 27/07/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import Foundation

class BloodPressure: NSObject {
    
    var uid: String
    var userName: String
    
    var systolic : Float
    var diastolic : Float
    var date : String
    var sourceType : String
    
    
    init(uid: String, userName: String, systolic: Float, diastolic: Float,date: String, sourceType: String) {
        self.uid = uid
        self.userName = userName
        self.systolic = systolic
        self.diastolic = diastolic
        self.date = date
        self.sourceType = sourceType
    }
    
    convenience override init() {
        self.init(uid: "", userName: "", systolic:  0.0, diastolic: 0.0, date: "", sourceType: "")
    }
}