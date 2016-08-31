//
//  FirebaseDataService.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 16/06/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FirebaseDataService {
    
    
    
    static let firebaseDataService = FirebaseDataService()
    
    var _Base_REF = FIRDatabase.database().reference()
    
    var BASE_REF:FIRDatabaseReference {
        return _Base_REF
    }
    
    
    var users = [UserObj]()
    var symptoms = [SymptomsModel]()

    
    func FirebaseSignUp(name: String, lastname: String, username: String, email: String, password: String) {
        
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: {
            user, error in
            if error != nil {
                print("There was an error when creating a user")
                print(error)
                
            }
            else {
                print("User created on Firebase")
                
                let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                let username = username
                let name = name
                let lastname = lastname
                
                changeRequest?.displayName = username
                changeRequest?.commitChangesWithCompletion() { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    // [START basic_write]
                    
                    let userData = ["username": username,
                                    "name": name,
                                    "last-name": lastname,
                                    "uid": user!.uid
                    ]
                    self.BASE_REF.child("users").child(user!.uid).setValue(userData)
                    
                    
                    
                }
                

                //self.login()
                self.FirebaseLogIn(email, password: password)
//                FIRAuth.auth()?.signInWithEmail(email, password: password, completion: {
//                    user, error in
//                    if error != nil {
//                        print("- Email or password not valid. Error: ", error?.localizedDescription)
//                    } else if let user = user {
//                        self.BASE_REF.child("users").child(user.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
//                            if (!snapshot.exists()) {
//                                print("user exists and you have  NOT logged in", snapshot)
//                            } else {
//                                print("you have logged in")
//                                print("Logged with new method")
//                                
//                                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                                appDelegate.login()
//                                
//                            }
//
//                        })
//                    }
//                    
//                })
                
                
                
            }
        })
        
    }
    
    func FirebaseLogIn(email: String, password: String) {
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: {
            user, error in
            if error != nil {
                print("- Email or password not valid. Error: ", error?.localizedDescription)
            } else if let user = user {
                self.BASE_REF.child("users").child(user.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if (!snapshot.exists()) {
                        print("user exists and you have  NOT logged in", snapshot)
                    } else {
                        //self.performSegueWithIdentifier("unwindToStudy", sender: nil)
                        print("you have logged in")
                        print("Logged with new method")
                        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.login()
                        
                    }
                })
            }
        })
        
    }
    
    
    func getUserName() -> (String) {
        
        var username = ""
        if FIRAuth.auth()?.currentUser != nil {
            
            username = (FIRAuth.auth()?.currentUser!.displayName)!
            //print("- Returning  Username: ", username)
        }
        return username
    }
    

    func sendNewWeightToFireBase(userID: String, username: String, measurement: Float, date: String, sourceType: String) {
        
        
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
        // [START write_fan_out]
        let key = BASE_REF.child("posts").childByAutoId().key
        let weightPost = ["uid": userID,
                          "username": username,
                          "measurement": measurement,
                          "source": sourceType,
                          "date": date]
        //let childUpdates = ["/weights/\(key)": weightPost,
        //                    "/user-weights/\(userID)/\(key)/": weightPost]
        
        let childUpdates = ["/user-weights/\(userID)/\(key)/": weightPost]
        BASE_REF.updateChildValues(childUpdates)
        // [END write_fan_out]
    }
    
    func sendNewBloodPressureToFireBase(userID: String, username: String, systolic: Float, diastolic: Float, date: String, sourceType: String) {
        
        
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
        // [START write_fan_out]
        let key = BASE_REF.child("posts").childByAutoId().key
        let bloodPressurePost = ["uid": userID,
                          "username": username,
                          "systolic": systolic,
                          "diastolic": diastolic,
                          "source": sourceType,
                          "date": date]
        //let childUpdates = ["/weights/\(key)": weightPost,
        //                    "/user-weights/\(userID)/\(key)/": weightPost]
        
        let childUpdates = ["/user-bps/\(userID)/\(key)/": bloodPressurePost]
        BASE_REF.updateChildValues(childUpdates)
        // [END write_fan_out]
    }
    
    func sendNewHeartRateToFireBase(userID: String, username: String, measurement: Float, date: String, sourceType: String) {
        
        
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
        // [START write_fan_out]
        let key = BASE_REF.child("posts").childByAutoId().key
        let heartRatePost = ["uid": userID,
                                 "username": username,
                                 "measurement": measurement,
                                 "source": sourceType,
                                 "date": date]
        //let childUpdates = ["/weights/\(key)": weightPost,
        //                    "/user-weights/\(userID)/\(key)/": weightPost]
        
        let childUpdates = ["/user-heartrates/\(userID)/\(key)/": heartRatePost]
        BASE_REF.updateChildValues(childUpdates)
        // [END write_fan_out]
    }
    
    func sendNewSymptomsToFireBase(userID: String, username: String, symptom1: String, symptom1Context: String, symptom2: String, symptom2Frequency: String, symptom3: String, symptom4: String, symptom5: String, date: String) {
        
        
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
        // [START write_fan_out]
        let key = BASE_REF.child("posts").childByAutoId().key
        let symptomsPost = ["uid": userID,
                                 "username": username,
                                 "symptom1": symptom1,
                                 "symptom1Context": symptom1Context,
                                 "symptom2": symptom2,
                                 "symptom2Frequency": symptom2Frequency,
                                 "symptom3": symptom3,
                                 "symptom4": symptom4,
                                 "symptom5": symptom5,
                                 "date": date
                                 ]
        //let childUpdates = ["/weights/\(key)": weightPost,
        //                    "/user-weights/\(userID)/\(key)/": weightPost]
        
        let childUpdates = ["/user-symptoms/\(userID)/\(key)/": symptomsPost]
        BASE_REF.updateChildValues(childUpdates)
        // [END write_fan_out]
    }

    
    func fetchSymptoms(userName : String,  callback:([SymptomsModel])->Void) -> Void {
        
        // Avoid exponential incremental of symptoms each time methods is being called from Timeline - viewdidappear
        symptoms = []
        
        self.BASE_REF.child("user-symptoms").observeEventType(.ChildAdded, withBlock: { snapshot in
            for child in snapshot.children.reverse() {
                
                let lastWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYear, value: -2, toDate: NSDate(), options: NSCalendarOptions())!
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd, MM, yy"
                
                let date = child.value["date"] as? String
                // Back to NSDate format
                let date_shorter_formatted = dateFormatter.dateFromString(date!.substringWithRange(date!.startIndex.advancedBy(0) ..< date!.startIndex.advancedBy(10)))!
                
                if (lastWeekDate.compare(date_shorter_formatted) == .OrderedAscending)   {
                    
                    let symptom1 = child.value["symptom1"] as? String
                    let symptom1Context = child.value["symptom1Context"] as? String
                    let symptom2 = child.value["symptom2"] as? String
                    let symptom2Frequency = child.value["symptom2Frequency"] as? String
                    let symptom3 = child.value["symptom3"] as? String
                    let symptom4 = child.value["symptom4"] as? String
                    let symptom5 = child.value["symptom5"] as? String
                    let date = child.value["date"] as? String


                    let username = child.value["username"] as? String
                    //let date = child.value["date"] as? String
                    let symptomsOne = SymptomsModel()
                    if userName == username {
                        symptomsOne.userName = username!
                        symptomsOne.symptom1 = symptom1!
                        symptomsOne.symptom1Context = symptom1Context!
                        symptomsOne.symptom2 = symptom2!
                        symptomsOne.symptom2Frequency = symptom2Frequency!
                        symptomsOne.symptom3 = symptom3!
                        symptomsOne.symptom4 = symptom4!
                        symptomsOne.symptom5 = symptom5!
                        symptomsOne.date = date!
                        
                       
                        self.symptoms.append(symptomsOne)
                    }
                }
                
            }
            callback(self.symptoms)
        })
    }
    
    
    
    func sendPatientAsUnstable(userID: String, username: String, weight: Int, bp: Int, hr: Int, numberOfSymptoms: Int, counter: Int, date: String) {
        
        
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
        // [START write_fan_out]
        //let key = BASE_REF.child("posts").childByAutoId().key
        //let key = "KPk6vBEHM2LKHYuH51N"
        let unstablePost = ["uid": userID,
                          "username": username,
                          "weight": weight,
                          "bp": bp,
                          "hr": hr,
                          "symptom": numberOfSymptoms,
                          "count": counter,
                          "date": date]
        //let childUpdates = ["/weights/\(key)": weightPost,
        //                    "/user-weights/\(userID)/\(key)/": weightPost]
        
//        let childUpdates = ["/unstable-users/\(userID)/\(key)/": unstablePost]
        let childUpdates = ["/diagnostic-users/\(userID)/": unstablePost]

        BASE_REF.updateChildValues(childUpdates)
        // [END write_fan_out]
    }
    
    func sendPatientReportToNurse(userID: String, username: String, weightValue: Float, weighValueAdvice: String, bloodPressureValue: Float, bloodPressureAdvice: String, heartRateValue: Float, heartRateAdvice: String, symptomSwelling: String, symptom1TodayAndYesterday: String, symptomSleep: String, symptomNausea: String, symptomDizziness: String, symptomCough: String, counter: Int, date: String) {
        
        
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
        // [START write_fan_out]
        //let key = BASE_REF.child("posts").childByAutoId().key
        //let key = "KPk6vBEHM2LKHYuH51N"
        let report = [      "uid": userID,
                            "username": username,
                            
                            "weightValue": weightValue,
                            "weighValueAdvice": weighValueAdvice,
                            
                            "bloodPressureValue": bloodPressureValue,
                            "bloodPressureAdvice": bloodPressureAdvice,
                            
                            "heartRateValue": heartRateValue,
                            "heartRateAdvice": heartRateAdvice,
                            
                            //"symptom1Advice": symptom1Advice,
                            "symptomSwelling": symptomSwelling,
                            "symptom1TodayAndYesterday": symptom1TodayAndYesterday,
                            "symptomSleep": symptomSleep,
                            
                            "symptomNausea": symptomNausea,
                            "symptomDizziness": symptomDizziness,
                            "symptomCough": symptomCough,
                            
                            "count": counter,
                            "date": date]
        
        
        //let childUpdates = ["/weights/\(key)": weightPost,
        //                    "/user-weights/\(userID)/\(key)/": weightPost]
        
        //        let childUpdates = ["/unstable-users/\(userID)/\(key)/": unstablePost]
        let childUpdates = ["/report-to-nurse/\(userID)/": report]
        
        BASE_REF.updateChildValues(childUpdates)
        // [END write_fan_out]
    }
    
    
}
