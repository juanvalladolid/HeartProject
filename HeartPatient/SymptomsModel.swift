//
//  SymptomsModel.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 18/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit

class SymptomsModel: NSObject {
    
    var uid: String
    var userName: String
    
    var symptom1 : String
    var symptom1Context : String
    var symptom2 : String
    var symptom2Frequency : String
    var symptom3 : String
    var symptom4 : String
    var symptom5 : String
    var date : String


    init(uid: String, userName: String, symptom1: String, symptom1Context : String, symptom2: String, symptom2Frequency: String, symptom3: String, symptom4: String,  symptom5: String, date: String) {
        self.uid = uid
        self.userName = userName
        self.symptom1 = symptom1
        self.symptom1Context = symptom1Context
        self.symptom2 = symptom2
        self.symptom2Frequency = symptom2Frequency
        self.symptom3 = symptom3
        self.symptom4 = symptom4
        self.symptom5 = symptom5
        self.date = date
    }
    
    convenience override init() {
        self.init(uid: "", userName: "", symptom1: "", symptom1Context: "", symptom2: "", symptom2Frequency: "", symptom3: "", symptom4: "", symptom5: "", date: "")
    }
}