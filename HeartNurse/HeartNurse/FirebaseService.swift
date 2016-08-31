//
//  FirebaseService.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 27/07/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class FirebaseService {
    
    
    
    static let firebaseService = FirebaseService()
    
    private var _Base_REF = FIRDatabase.database().reference()
    
    var BASE_REF: FIRDatabaseReference {
        return _Base_REF
    }
    
    var postKey = ""
    var users = [User]()
    var unstablePatient = [SummaryPatient]()
    var stablePatient = [SummaryPatient]()
    
    var summaryToNurse = [SummaryToNurse]()

    var weightSamples = [Weight]()
    var bloodPressureSamples = [BloodPressure]()
    var heartRateSamples = [HeartRate]()
    
    
    func FirebaseSignUp(username: String, email: String, password: String) {
        
        
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
                
                changeRequest?.displayName = username
                changeRequest?.commitChangesWithCompletion() { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    // [START basic_write]
                    self.BASE_REF.child("users").child(user!.uid).setValue(["username": username])
                }
                
                //self.login()
                //self.FirebaseLogIn(email, password: password)
                FIRAuth.auth()?.signInWithEmail(email, password: password, completion: {
                    user, error in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else if let user = user {
                        self.BASE_REF.child("users").child(user.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                            if (!snapshot.exists()) {
                                print("user exists and you have  NOT logged in", snapshot)
                            } else {
                                print("you have logged in")
                                print("Logged with new method")
                                
                                //let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                //appDelegate.login()
                                
                            }
                            
                        })
                    }
                    
                })
                
                
                
            }
        })
        
    }
    
    func FirebaseLogIn(email: String, password: String) {
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: {
            user, error in
            if error != nil {
                print("- email or password not valid", error?.localizedDescription)
            } else if let user = user {
                self.BASE_REF.child("users").child(user.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if (!snapshot.exists()) {
                        print("User exists but you dont have a username", snapshot)
                    } else {
                        //self.performSegueWithIdentifier("unwindToStudy", sender: nil)
                        print("you have logged in")
                        print("Logged with new method")
                        //let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        //appDelegate.login()
                        
                    }
                })
            }
        })
        
    }
    
    
    func fetchUsers(callback:([User])->Void) -> Void {
        
        print("fetch users method")
        self.BASE_REF.child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Get user value
            
            self.users = []
            for child in snapshot.children {
                
                if let users = child.value["username"] as? String {
                    let newUser = User()
                    let key = child.value["uid"] as? String
                    newUser.uid = key!
                    newUser.userName = users
                    self.users.append(newUser)
//                    print("- These are the appended users: ", users, child)
                }
            }
            for wgbd in self.users {
                
                print("- All patients: \(wgbd.userName)")
                
            }
            
            callback(self.users)
            
            
        })
        
    }
    
    func fetchUnstablePatient(callback:([SummaryPatient])->Void) -> Void {
        
        print("fetch unstable users method")
        
        self.BASE_REF.child("diagnostic-users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Get user value
            
            self.unstablePatient = []
            for child in snapshot.children {
                
                if let user = child.value["username"] as? String {
                    let newUnstablePatient = SummaryPatient()
                    
                    let uid = child.value["uid"] as? String
                    
                    let counters = child.value["count"] as! Int
                    let weight = child.value["weight"] as! Int
                    let bp = child.value["bp"] as! Int
                    let hr = child.value["hr"] as! Int
                    let symptoms = child.value["symptom"] as! Int
                    
                    if counters >= 1 {
                        
                        newUnstablePatient.userName = user
                        newUnstablePatient.uid = uid!
                        newUnstablePatient.weight = weight
                        newUnstablePatient.bloodPressure = bp
                        newUnstablePatient.symptom = symptoms
                        newUnstablePatient.heartRate = hr
                        self.unstablePatient.append(newUnstablePatient)

                        print("- found patient")
                    }
                }
            }
            for wgbd in self.unstablePatient {
                print("- Unstable patients background: \(wgbd.userName)")
            }
            
            callback(self.unstablePatient)
            
        })
    }
    
    
    func fetchStablePatient(callback:([SummaryPatient])->Void) -> Void {
        
        print("fetch stable users method")
        
        self.BASE_REF.child("diagnostic-users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Get user value
            
            self.stablePatient = []
            for child in snapshot.children {
                
                if let users = child.value["username"] as? String {
                    let newUser = SummaryPatient()
                    
                    let uid = child.value["uid"] as? String

                    newUser.userName = users
                    newUser.uid = uid!
                    
                    let counters = child.value["count"] as? Int
                    
                    if counters! <= 0 {
                        self.stablePatient.append(newUser)
                        print("- found stable patients: ")
                    }
                }
            }
            for wgbd in self.stablePatient {
                print("- Stable patients background: \(wgbd.userName)")
            }
            
            callback(self.stablePatient)
            
        })
    }

    
    
    func fetchWeightSamples(userName : String,  callback:([Weight])->Void) -> Void {
        print("- Fetch weights from 2 weeks ago")
        self.BASE_REF.child("user-weights").observeEventType(.ChildAdded, withBlock: { snapshot in
            
            //self.weightSamples = []

            for child in snapshot.children.reverse() {
                
                let lastWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYear, value: -3, toDate: NSDate(), options: NSCalendarOptions())!
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd, MM, yy"
                
                let date = child.value["date"] as? String
                // Back to NSDate format
                let date_shorter_formatted = dateFormatter.dateFromString(date!.substringWithRange(date!.startIndex.advancedBy(0) ..< date!.startIndex.advancedBy(10)))!
                
                if (lastWeekDate.compare(date_shorter_formatted) == .OrderedAscending)   {
                    
                    let measurement = child.value["measurement"] as? Float
                    let username = child.value["username"] as? String
                    //let date = child.value["date"] as? String
                    let weightData = Weight()
                    if userName == username {
                        weightData.userName = username!
                        weightData.measurement = measurement!
                        weightData.date = date!
                        self.weightSamples.append(weightData)
                    }
                }
                
            }
            callback(self.weightSamples)
        })
    }
    
    
    func fetchBloodPressureSamples(userName : String,  callback:([BloodPressure])->Void) -> Void {
        print("- Fetch Blood Pressures from 2 weeks ago")
        self.BASE_REF.child("user-bps").observeEventType(.ChildAdded, withBlock: { snapshot in
           
            //self.bloodPressureSamples = []

            for child in snapshot.children.reverse() {
                
                let lastWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYear, value: -2, toDate: NSDate(), options: NSCalendarOptions())!
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd, MM, yy"
                
                let date = child.value["date"] as? String
                // Back to NSDate format
                let date_shorter_formatted = dateFormatter.dateFromString(date!.substringWithRange(date!.startIndex.advancedBy(0) ..< date!.startIndex.advancedBy(10)))!
                
                if (lastWeekDate.compare(date_shorter_formatted) == .OrderedAscending)   {
                    
                    let systolic = child.value["systolic"] as? Float
                    let diastolic = child.value["diastolic"] as? Float
                    
                    let username = child.value["username"] as? String
                    //let date = child.value["date"] as? String
                    let bloodPressureOne = BloodPressure()
                    if userName == username {
                        bloodPressureOne.userName = username!
                        bloodPressureOne.systolic = systolic!
                        bloodPressureOne.diastolic = diastolic!
                        bloodPressureOne.date = date!
                        self.bloodPressureSamples.append(bloodPressureOne)
                    }
                }
                
            }
            callback(self.bloodPressureSamples)
        })
    }
    
    func fetchHeartRateSamples(userName : String,  callback:([HeartRate])->Void) -> Void {
        print("- Fetch Heart Rates from 2 weeks ago")
        self.BASE_REF.child("user-heartrates").observeEventType(.ChildAdded, withBlock: { snapshot in
            //self.heartRateSamples = []

            for child in snapshot.children.reverse() {
                
                let lastWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYear, value: -2, toDate: NSDate(), options: NSCalendarOptions())!
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd, MM, yy"
                
                let date = child.value["date"] as? String
                // Back to NSDate format
                let date_shorter_formatted = dateFormatter.dateFromString(date!.substringWithRange(date!.startIndex.advancedBy(0) ..< date!.startIndex.advancedBy(10)))!
                
                if (lastWeekDate.compare(date_shorter_formatted) == .OrderedAscending)   {
                    
                    let measurement = child.value["measurement"] as? Float
                    
                    let username = child.value["username"] as? String
                    //let date = child.value["date"] as? String
                    let heartRateOne = HeartRate()
                    if userName == username {
                        heartRateOne.userName = username!
                        heartRateOne.measurement = measurement!
                        heartRateOne.date = date!
                        self.heartRateSamples.append(heartRateOne)
                    }
                }
                
            }
            callback(self.heartRateSamples)
        })
    }
    
    func fetchUnstablePatient2(callback:([SummaryPatient])->Void) -> Void {
        
        print("fetch unstable users method")
        
        self.BASE_REF.child("diagnostic-users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Get user value
            
            self.unstablePatient = []
            for child in snapshot.children {
                
                if let user = child.value["username"] as? String {
                    let newUnstablePatient = SummaryPatient()
                    
                    let counters = child.value["count"] as! Int
                    let weight = child.value["weight"] as! Int
                    let bp = child.value["bp"] as! Int
                    let hr = child.value["hr"] as! Int
                    let symptoms = child.value["symptom"] as! Int
                    
                    if counters >= 1 {
                        
                        newUnstablePatient.userName = user
                        newUnstablePatient.weight = weight
                        newUnstablePatient.bloodPressure = bp
                        newUnstablePatient.symptom = symptoms
                        newUnstablePatient.heartRate = hr
                        self.unstablePatient.append(newUnstablePatient)
                        
                        print("- found patient")
                    }
                }
            }
            for wgbd in self.unstablePatient {
                print("- Unstable patients background: \(wgbd.userName)")
            }
            
            callback(self.unstablePatient)
            
        })
    }


    
    func fetchSummaryToNurse(userName : String,  callback:([SummaryToNurse])->Void) -> Void {
        print("- Fetch Summary To Nurse from Firebase!")
        
        
        self.BASE_REF.child("report-to-nurse").observeSingleEventOfType(.Value, withBlock: { snapshot in

            //self.heartRateSamples = []
            
            for child in snapshot.children {
                
                let username = child.value["username"] as? String
                
                if  userName == username{
                    let summaryToNurseOne = SummaryToNurse()
                    
                    let weightValue = child.value["weightValue"] as? Float
                    let weighValueAdvice = child.value["weighValueAdvice"] as? String
                    
                    let bloodPressureValue = child.value["bloodPressureValue"] as? Float
                    let bloodPressureAdvice = child.value["bloodPressureAdvice"] as? String

                    let heartRateValue = child.value["heartRateValue"] as? Float
                    let heartRateAdvice = child.value["heartRateAdvice"] as? String
                    
                    let symptom1TodayAndYesterday = child.value["symptom1TodayAndYesterday"] as? String
                    let symptomSwelling = child.value["symptomSwelling"] as? String
                    let symptomSleep = child.value["symptomSleep"] as? String
                    
                    let symptomNausea = child.value["symptomNausea"] as? String
                    let symptomCough = child.value["symptomCough"] as? String

                    let date = child.value["date"] as? String

                    let counters = child.value["count"] as? Int
                    
                    summaryToNurseOne.userName = userName
                    summaryToNurseOne.weightValue = weightValue!
                    summaryToNurseOne.weightAdvice = weighValueAdvice!
                    
                    summaryToNurseOne.bloodPressureValue = bloodPressureValue!
                    summaryToNurseOne.bloodPressureAdvice = bloodPressureAdvice!
                    
                    summaryToNurseOne.heartRateValue = heartRateValue!
                    summaryToNurseOne.heartRateAdvice = heartRateAdvice!
                    
                    summaryToNurseOne.symptom1TodayAndYesterday = symptom1TodayAndYesterday!
                    
                    summaryToNurseOne.symptomSwelling = symptomSwelling!
                    summaryToNurseOne.symptomSleep = symptomSleep!
                    
                    summaryToNurseOne.symptomNausea = symptomNausea!
                    summaryToNurseOne.symptomCough = symptomCough!
                    summaryToNurseOne.date = date!
                    summaryToNurseOne.count = counters!
                    
                    self.summaryToNurse.append(summaryToNurseOne)
                    
                }
            }
            
            for i in self.summaryToNurse {
                print("*** Summary to nurse from Firebase method: ", i.date, i.symptom1TodayAndYesterday)
            }
            
            callback(self.summaryToNurse)
        })
    }
    
    
    func sendMedicineFromNurseTo(userID: String, username: String, date: String,
                                 
                                 aceInhibitorType: String, aceInhibitorDose: String, aceInhibitorTimes: String,
                                 
                                 betaBlockerType: String, betaBlockerDose: String, betaBlockerTimes: String,
                                 
                                 diureticType: String, diureticDose: String, diureticTimes: String,
                                 
                                 arbType: String, arbDose: String,  arbTimesADay: String,
                                 
                                 mraType: String, mraDose: String, mraTimesADay: String) {
        
        
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
        // [START write_fan_out]
        //let key = userID
        //let key = "KPk6vBEHM2LKHYuH51N"
        
        let key = BASE_REF.child("posts").childByAutoId().key

        let report = [      "uid": userID,
                            "username": username,
                            "date": date,
                            "aceInhibitorType": aceInhibitorType,
                            "aceInhibitorDose": aceInhibitorDose,
                            "aceInhibitorTimes": aceInhibitorTimes,
                            
                            "betaBlockerType": betaBlockerType,
                            "betaBlockerDose": betaBlockerDose,
                            "betaBlockerTimes": betaBlockerTimes,
                            
                            "diureticType": diureticType,
                            "diureticDose": diureticDose,
                            "diureticTimes": diureticTimes,
                            
                            "arbType": arbType,
                            "arbDose": arbDose,
                            "arbTimesADay": arbTimesADay,
                            
                            "mraType": mraType,
                            "mraDose": mraDose,
                            "mraTimesADay": mraTimesADay
                      ]
        let childUpdates = ["/medicine-from-nurse/\(userID)/\(key)/": report]

        //let childUpdates = ["/medicine-from-nurse/\(userID)/": report]
        
        BASE_REF.updateChildValues(childUpdates)
        // [END write_fan_out]
    }
    
    


    
}
