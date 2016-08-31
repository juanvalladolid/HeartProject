//
//  User.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 17/06/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import Foundation
class User: NSObject {
    
    var uid: String
    var userName: String
    

    
    
    init(uid: String, userName: String) {
        self.uid = uid
        self.userName = userName

    }
    
    convenience override init() {
        self.init(uid: "", userName: "")
    }
}