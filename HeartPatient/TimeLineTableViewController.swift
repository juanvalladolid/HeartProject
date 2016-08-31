//
//  TimeLineTableViewController.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 03/06/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import HealthKit
import ResearchKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TimeLineTableViewController: UITableViewController, UIApplicationDelegate{
    
    var refTimeLine:FIRDatabaseReference!
    var dataService:FirebaseDataService = FirebaseDataService()

    
    let healthManager:HealthManager = HealthManager()
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    var height, bmi, weight:HKQuantitySample?
    
    var weightsGroupedByDate = [Weight]()
    var heartRateSamples = [HeartRate]()
    var newParameters = [AnyObject]()
    var symptomSamples = [SymptomsModel]()
    
    var medicineSamples = [Medicine]()
    
    var patientSample = [SummaryPatient]()

    
    var bloodPressureSamples = [BloodPressure]()
    

    
    let valueRemindHour = 10
    let valueRemindMinute = 0
    
    @IBOutlet var weightValueLabel: UILabel!
    @IBOutlet var checkWeightImage: UIImageView!
    @IBOutlet var weightImage: UIImageView!
    @IBOutlet var weightTime: UILabel!
    
    @IBOutlet var checkBloodPImage: UIImageView!
    @IBOutlet var bloodPressureImage: UIImageView!
    @IBOutlet var bloodPressureValueLabel: UILabel!
    @IBOutlet var bloodPressureTime: UILabel!
    
    @IBOutlet weak var heartRateValueLabel: UILabel!
    @IBOutlet weak var heartRateTimeLabel: UILabel!
    @IBOutlet var heartRateImage: UIImageView!
    
    @IBOutlet weak var todayLabel: UILabel!
    

    @IBOutlet var symptomsAndSleepImage: UIImageView!
    @IBOutlet var checkSymptomsImage: UIImageView!
    @IBOutlet var symptomsAndSleepLabel: UILabel!
    @IBOutlet var confirmationSymptomsLabel: UILabel!
    
    
    @IBOutlet weak var morningPillsLabel: UILabel!
    
    @IBOutlet weak var afternoonPillsLabel: UILabel!
    
    @IBOutlet weak var eveningPillsLabel: UILabel!
    
    
    
    let filledColors = UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0)
    let filledColorGray = (UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0))

    // MARK: Propertues
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // [START create_database_reference]
        self.refTimeLine = FIRDatabase.database().reference()
        // [END create_database_reference]
        self.imagesColors()
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Background {
            appDelegate.lockApp()
            //print("- Lock app from TimeLineViewController")
        }
        
        

        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("- HealthKit authorization received.")
            }
            else {
                print("- HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
        
        self.patientAnalysis()

//
//        self.updateWeight()
//        self.readSampleByBloodPressure()
//        self.updateHeartRate()
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("XXX - VIEW DID APPEAR - XXX")
        
        self.nameAndDate()
        

        self.heartRatesToFirebase()

        self.patientAnalysis()

        
        self.updateWeight()
        self.readSampleByBloodPressure()
        self.updateHeartRate()

        self.symptomsFromDataBase()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.patientAnalysis()

    }
    

    
    func nameAndDate() {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        //let username = self.dataService.getUserName()
        var name = ""
        self.refTimeLine.child("users").child(FIRAuth.auth()!.currentUser!.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            name = String(snapshot.value!["name"]!!)
            self.todayLabel.text = dateFormatter.stringFromDate(date) + "\n" + name + ", your activities today:"
            
        })
    }
    
    func imagesColors() {
        //print("- TESTING IMAGES COLOR")
        
        let weightImageTimeLine = UIImage(named: "weight")
        self.weightImage.image = weightImageTimeLine!.tintWithColor(filledColorGray)
        let weightCheckTimeLine = UIImage(named: "unchecked")
        self.checkWeightImage.image = weightCheckTimeLine?.tintWithColor(filledColorGray)
        
        let bpImageTimeLine = UIImage(named: "blood2")
        self.bloodPressureImage.image = bpImageTimeLine!.tintWithColor(filledColorGray)
        let bpCheckTimeLine = UIImage(named: "unchecked")
        self.checkBloodPImage.image = bpCheckTimeLine?.tintWithColor(filledColorGray)
        
        let feelingsTimeLine = UIImage(named: "feeling")
        self.symptomsAndSleepImage.image = feelingsTimeLine!.tintWithColor(filledColorGray)
        let symptomsCheckTimeLine = UIImage(named: "unchecked")
        self.checkSymptomsImage.image = symptomsCheckTimeLine?.tintWithColor(filledColorGray)
        
        let hearRateImageTimeLine = UIImage(named: "heart-512")
        self.heartRateImage.image = hearRateImageTimeLine!.tintWithColor(filledColorGray)
    }
    
    
    func sendDataToSymptomsViewController() {
        
        let tabBar = self.tabBarController
        let navBar = tabBar!.viewControllers![1] as! UINavigationController
        
        let svc = navBar.topViewController as! SymptomsTableViewController
        svc.patientSample = self.patientSample
        svc.patientSymptoms = self.symptomSamples
        
        svc.patientWeights = self.weightsGroupedByDate
        svc.patientBPs = self.bloodPressureSamples
        svc.patientHRs = self.heartRateSamples
    }
    
    
    func patientAnalysis() {
        
        let patientOne = SummaryPatient()
        patientSample = []
        
        if self.symptomSamples.count > 0 || self.weightsGroupedByDate.count > 0 || self.bloodPressureSamples.count > 0 || self.heartRateSamples.count > 0 {
            
            
            var weightRecentMeasurement: Float = 0.0
            var weightDifference:Float = 0.0
            var weightStability: String = ""
            var measurementWithinLastThreeDays: Float = 0.0
            var weightAdvice: String = ""
            
            var recentSystolicBP: Float = 0.0
            var systolicStability: String = ""
            var bpAdvice: String = ""
            
            var recentHeartRate: Float = 0.0
            var heartRateStability: String = ""
            var hrAdvice: String = ""
            
            var degreeDyspneaYesterday = 0
            
            var symptom1 = ""
            var context = ""
            var degreeDyspnea = -1
            var degreeFatigue = 0
            
            var symptom1Yesterday = ""
            var contextYesterday = ""
            
            var symptom2 = ""
            var frequency = ""
            var degreeSymptom2 = ""
            
            var cough = ""
            var swollenBody = "No-Swollen"
            var sleepPosition = ""
            
            var weightEvaluation = 0
            var bpEvaluation = 0
            var hrEvaluation = 0
            var symptomEvaluation = 0
            
            var symptomSleep = ""
            var symptom1Advice = ""
            var symptom1TodayAndYesterday = ""
            var symptomSwelling = ""
            
            
            var weightAdviceNurse: String = ""
            var bloodPressureAdviceNurse: String = ""
            var heartRateAdviceNurse: String = ""
            
            var dyspneaAndContextYesterday = ""
            var dyspneaAndContextToday = ""

            
            var symptomSwellingNurse: String = ""
            var symptom1TodayAndYesterdayNurse: String = ""
            var symptomSleepNurse: String  = ""
            var symptomNauseaNurse: String = ""
            var symptomDizzinessNurse: String = ""
            var symptomCoughNurse: String = ""
            
            
            var symptomsToNurse = [Int]()
            
            
            if self.weightsGroupedByDate.count > 0 {
                
                if self.weightsGroupedByDate.count > 3 {
                    measurementWithinLastThreeDays = self.weightsGroupedByDate[3].measurement
                    
                } else if self.weightsGroupedByDate.count > 2 {
                    measurementWithinLastThreeDays = self.weightsGroupedByDate[2].measurement
                } else {
                    measurementWithinLastThreeDays = self.weightsGroupedByDate[1].measurement
                }
                
                
                let toDateWeight = HelperFunctions.shortString(self.weightsGroupedByDate[0].date)
                let todayString = HelperFunctions.convertDateToShortString(NSDate())
                
                if self.weightsGroupedByDate.count > 0 && (toDateWeight == todayString) {
                    
                    weightRecentMeasurement = self.weightsGroupedByDate[0].measurement
                    weightDifference = weightRecentMeasurement - measurementWithinLastThreeDays
                    
                    if weightDifference <= -2 {
                        weightAdvice = "Weight\nYou lost more than 2 kg (\(weightDifference) kg) the last 3 days. Consider reducing Diuretics, or else contact the Doctor very soon."
                        weightStability = "loss 2kg"
                        weightAdviceNurse = "Measurements' Summary\n\n- The patient has lost \(abs(weightDifference)) kg the last 3 days.\nIf any complaints (see above), considering lowering Diuretics dose"
                        
                    } else if weightDifference < -1 {
                        weightAdvice = "Weight\nYou lost more than 1 kg (\(weightDifference) kg) the last 3 days. Keep Track of it and see tomorrow."
                        weightStability = "loss 1kg"
                        weightAdviceNurse = "Measurements' Summary\n\n- The patient has lost \(abs(weightDifference)) kg the last 3 days."
                        
                    } else if weightDifference > 1 && weightDifference < 2 {
                        weightAdvice = "Weight\nYou gained more than 1 kg (\(weightDifference) kg) the last 3 days. Take care of your fuild intake and salt consumption. Do NOT drink more than 1500 ml a day."
                        weightStability = "gain 1kg"
                        weightAdviceNurse = "Measurements' Summary\n\n- The patient has gain \(abs(weightDifference)) kg the last 3 days."

                        
                    } else if weightDifference >= 2 {
                        weightAdvice = "Weight\nYou gained more than 2 kg (\(weightDifference) kg) the last 3 days. Consider increasing Diuretics, send your symptoms from the Timeline, or else contact the Doctor very soon."
                        weightStability = "gain 2kg"
                        weightAdviceNurse = "Measurements' Summary\n\n- The patient has gain \(abs(weightDifference)) kg the last 3 days.\nConsider uptitration of Diuretics if possible"

                        
                    } else {
                        weightAdvice = "Weight\nGood news, your weight has been stable the last 3 days."
                        weightStability = "stable weight"
                        weightAdviceNurse = "Measurements' Summary\n\n- The patient's weight has been stable the last 3 days."

                    }
                    
                    patientOne.weightValue = weightRecentMeasurement
                    patientOne.weightAdvice = weightAdvice
                    
                    print("Weight difference:  ", weightDifference, " weight-today: ", weightRecentMeasurement, " weight 3 days ago: ", measurementWithinLastThreeDays, "Weight stability: ", weightStability)
                    
                }
            }
            
           
            
            if self.bloodPressureSamples.count > 0 {
                self.bloodPressureSamples = self.bloodPressureSamples.reverse()
                let toDateBloodPressure = HelperFunctions.shortString(self.bloodPressureSamples[0].date)
                let todayString = HelperFunctions.convertDateToShortString(NSDate())
                
                if self.bloodPressureSamples.count > 3 && (toDateBloodPressure == todayString) {
                    
                    recentSystolicBP = self.bloodPressureSamples[0].systolic
                    
                    print("BLOOD PRESSURE ADVICE CHECK DATES: ", toDateBloodPressure, todayString, recentSystolicBP)

                    if recentSystolicBP > 120 {
                        bpAdvice = "Blood Pressure\nYour systolic blood pressure (SBP) is very high. Your SBP is \(recentSystolicBP) mmHg, however it should not be higher than 120 mmHg.\nTry measuring again and fill up your symptoms, or else contact the Doctor very soon for increasing your ACE Inhibitor dose."
                        systolicStability = "high bp"
                        bloodPressureAdviceNurse = "- Pantient's SBP is higher than normal (\(recentSystolicBP) mmHg).\nConsider uptitration of ACE-I/ARB and BetaBlocker if possible."
                    
                        
                    } else if recentSystolicBP < 90 {
                        bpAdvice = "Blood Pressure\nYour systolic blood pressure (SBP) is very low. Your SBP is \(recentSystolicBP) mmHg, however it should not be lower than 90 mmHg.\nTry measuring again and fill up your symptoms, or else contact the Doctor very soon for descreasing your ACE Inhibitor dose or changing to ARB."
                        systolicStability = "low bp"
                        // "Patient is currently using a ACE inhibitor and a beta-blocker. Monitor the blood pressure the coming day's
                        bloodPressureAdviceNurse = "- Paient's SBP is lower than normal (\(recentSystolicBP) mmHg).\nIf any complains (see above), consider lowering ACE-I/ARB dose."
                        
                    } else {
                        bpAdvice = "Blood Pressure\nGood news, your blood pressure is within normal range."
                        systolicStability = "stable bp"
                        bloodPressureAdviceNurse = "- The patient's SBP is stable."

                    }
                    
                    patientOne.bloodPressureValue = recentSystolicBP
                    patientOne.bloodPressureAdvice = bpAdvice
                }
            }
            
                
            
            
            if self.heartRateSamples.count > 0 {
                //self.heartRateSamples = self.heartRateSamples.reverse()
                let heartCounter = self.heartRateSamples.count-1
                let toDateHeartRate = HelperFunctions.shortString(self.heartRateSamples[heartCounter].date)
                let todayString = HelperFunctions.convertDateToShortString(NSDate())

                print("HEART RATE ADVICE CHECK DATE: ", toDateHeartRate, todayString)
                if self.heartRateSamples.count > 3  && (toDateHeartRate == todayString) {
                    recentHeartRate = self.heartRateSamples[heartCounter].measurement
                    
                    if recentHeartRate >= 70 {
                        hrAdvice = "Heart Rate\nYour resting heart rate (RHR) is very high. Your RHR is \(recentHeartRate) bpm, however it should not be higher than 70 bpm. REMEMBER to take your medicine.\nTry measuring again and fill up your symptoms, or else contact the Doctor very soon for increasing your Beta Blocker dose."
                        heartRateStability = "high hr"
                        heartRateAdviceNurse = "- Resting heart rate (RHR) is higher than normal \(recentHeartRate) bpm.\nConsider uptitration of BetaBlocker if possible."
                        
                    } else if recentHeartRate <= 50 {
                        hrAdvice = "Heart Rate\nYour resting heart rate (RHR) is very low. Your RHR is \(recentHeartRate) bpm, however it should not be lower than 50 bpm to be able to provide sufficient blood flow to the brain.\nTry measuring again and fill up your symptoms, or else contact the Doctor very soon for maybe lowering your Beta Blocker dose."
                        heartRateStability = "low hr"
                         heartRateAdviceNurse = "- Resting heart rate (RHR) is lower than normal \(recentHeartRate) bpm.\nIf any complains (see above), consider decreasing BetaBlocker dose."
                        
                    } else {
                        hrAdvice = "Heart Rate\nGood news, your resting heart rate \(recentHeartRate) is within normal range."
                        heartRateStability = "stable hr"
                        heartRateAdviceNurse = "- The patient's Heart Rate is stable"
                    }
                    print("HEART RATE STABILITY: ", heartRateStability, recentHeartRate)
                    
                    patientOne.heartRateValue = recentHeartRate
                    patientOne.heartRateAdvice = hrAdvice

                }
            }
            
            
            if self.symptomSamples.count > 0 {
                
                let styler = NSDateFormatter()
                styler.dateFormat = "dd-MM-yyyy"
                let cal = NSCalendar.currentCalendar()
                let yesterday = styler.stringFromDate(cal.dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])!)
                
                for i in 0 ..< self.symptomSamples.count {
                    
                    let dateSymptom = HelperFunctions.shortString(self.symptomSamples[i].date)
                    if dateSymptom == yesterday {
                        
                        symptom1Yesterday = self.symptomSamples[i].symptom1
                        contextYesterday = self.symptomSamples[i].symptom1Context
                        
                        //print("- yesterday evaluation ",dateSymptom, yesterday, symptom1, context)
                        
                        
                        if symptom1Yesterday == "ShortOfBreath" && contextYesterday == "Running" {
                            degreeDyspneaYesterday = 1
                            dyspneaAndContextYesterday = "Shortness of breath while running or high effort activities"
                            
                        } else if symptom1Yesterday == "ShortOfBreath" && contextYesterday == "Walking" {
                            degreeDyspneaYesterday = 2
                            dyspneaAndContextYesterday = "Shortness of breath while walking or moderate activities"

                            
                        } else if symptom1Yesterday == "ShortOfBreath" && contextYesterday == "Standing" {
                            degreeDyspneaYesterday = 3
                            dyspneaAndContextYesterday = "Shortness of breath while standing or during daily activites"

                            
                        } else if symptom1Yesterday == "ShortOfbreath" && contextYesterday == "Resting" {
                            degreeDyspneaYesterday = 4
                            dyspneaAndContextYesterday = "Shortness of breath at rest"

                            
                        } else if symptom1Yesterday == "No-ShortOfBreath-Fatigue" {
                            degreeDyspneaYesterday = 0
                            dyspneaAndContextYesterday = "No Shortness of breath"

                        }
                    }
                    
                }
                
                // Symptoms today
                
                let dateSymptomShorter = HelperFunctions.shortString(self.symptomSamples[0].date)
                
                let todayString = HelperFunctions.convertDateToShortString(NSDate())
                
                
                if  todayString == dateSymptomShorter {
                    
                    symptom1 = self.symptomSamples[0].symptom1
                    context = self.symptomSamples[0].symptom1Context
                    
                    symptom2 = self.symptomSamples[0].symptom2
                    frequency = self.symptomSamples[0].symptom2Frequency
                    
                    cough = self.symptomSamples[0].symptom3
                    
                    swollenBody = self.symptomSamples[0].symptom4
                    
                    sleepPosition = self.symptomSamples[0].symptom5
                    
                    
                    if symptom1 == "ShortOfBreath" && context == "Running" {
                        degreeDyspnea = 1
                        dyspneaAndContextToday = "Shortness of breath while running or high effort activities"

                        
                    } else if symptom1 == "ShortOfBreath" && context == "Walking" {
                        degreeDyspnea = 2
                        dyspneaAndContextToday = "Shortness of breath while walking or moderate activities"

                        
                    } else if symptom1 == "ShortOfBreath" && context == "Standing" {
                        degreeDyspnea = 3
                        dyspneaAndContextToday = "Shortness of breath while walking or during daily activities"

                        
                    } else if symptom1 == "ShortOfBreath" && context == "Resting" {
                        degreeDyspnea = 4
                        dyspneaAndContextToday = "Shortness of breath at rest"
                        
                    } else if symptom1 == "No-ShortOfBreath-Fatigue" {
                        degreeDyspnea = 0
                        degreeFatigue = 0
                        dyspneaAndContextToday = "No Shortness of breath"

                        
                    } else if symptom1 == "FatigueAndTiredness" && context == "Running" {
                        degreeFatigue = 1
                        
                    } else if symptom1 == "FatigueAndTiredness" && context == "Walking" {
                        degreeFatigue = 2
                        
                    } else if symptom1 == "FatigueAndTiredness" && context == "Standing" {
                        degreeFatigue = 3
                        
                    } else if symptom1 == "FatigueAndTiredness" && context == "Resting" {
                        degreeFatigue = 4
                    } else {
                    }
                    
                    
                    if symptom2 == "Nausea" && frequency == "Frequent" {
                        degreeSymptom2 = "Frequent Nausea"
                        symptomNauseaNurse = "- Patient presents Frequent episodes of Nausea"
                        symptomEvaluation = 1

                        
                    } else if symptom2 == "Nausea" && frequency == "Sometimes" {
                        degreeSymptom2 = "Sometimes Nausea"
                        symptomNauseaNurse = "- Patient presents Some episodes of Nausea"
                        symptomEvaluation = 1

                        
                    } else if symptom2 == "Nausea" && frequency == "Rare" {
                        degreeSymptom2 = "Rare Nausea"
                        
                        
                    } else if symptom2 == "Dizziness" && frequency == "Frequent" {
                        degreeSymptom2 = "Frequent Dizziness"
                        symptomDizzinessNurse = "- Patient presents Frequent episodes of Dizziness"
                        symptomEvaluation = 1

                        
                    } else if symptom2 == "Dizziness" && frequency == "Sometimes" {
                        degreeSymptom2 = "Sometimes Dizziness"
                        symptomDizzinessNurse = "- Patient presents Some episodes of Dizziness"
                        symptomEvaluation = 1

                        
                    } else if symptom2 == "Dizziness" && frequency == "Rare" {
                        degreeSymptom2 = "Rare Dizziness"
                        
                    } else {
                        degreeSymptom2 = "no symptom2"
                    }
                    
                }
            }
            
            
            /* Begins Patient's and Nurse's Report */

            
            var countUnstability = 0
            
            var diuretic = 0
            var ace_i = 0
            var beta_blocker = 0
            var nurseConfirmation = -1
            
            if weightStability == "gain 2kg" && swollenBody != "No-Swollen" {
                print("increase diuretics")
                diuretic = 1
            } else
            
            if (degreeDyspnea > degreeDyspneaYesterday) && (weightStability == "gain 2kg" ||
                swollenBody != "No-Swollen" || sleepPosition == "vertical") {
                
                diuretic = 1
                ace_i = -1
                beta_blocker = -1

                print("increase diuretics")
                print("decrease ace-i")
                print("decrease beta blocker")
                    
            } else

            
            if weightStability == "less 2kg" && swollenBody == "No-Swollen" {
                print("decrease diuretics")
                diuretic = -1

            } else
            
            if systolicStability == "high bp" {
                print("increase ace-i")
                ace_i = 1

            }
            
            if systolicStability == "low bp" {
                print("decrease ace-i")
                ace_i = -1

            } else
            
            if heartRateStability == "high hr" {
                print("increase beta blocker")
                beta_blocker = 1

            } else
            
            if heartRateStability == "low hr" {
                print("decrease beta blocker")
                beta_blocker = -1

            }
           
            
            /* ends medicine */
            
            
            if weightStability == "gain 2kg"  {
                countUnstability = 1
                symptomsToNurse.append(1)
                weightEvaluation = 1
                symptomEvaluation = 1
            }
            
            if systolicStability == "high bp" || systolicStability == "low bp"{
                countUnstability = countUnstability + 1
                symptomsToNurse.append(2)
                bpEvaluation = 1
                symptomEvaluation = symptomEvaluation + 1
            }
            
            if heartRateStability == "high hr" || heartRateStability == "low hr"{
                countUnstability = countUnstability + 1
                symptomsToNurse.append(3)
                hrEvaluation = 1
                symptomEvaluation = symptomEvaluation + 1
            }
            
            if (degreeDyspnea > degreeDyspneaYesterday) {
                symptom1Advice = "Shortness of Breath\n\nYou are experiencing worsening in your SHORTNESS OF BREATH, please REMEMBER to take your medicine and check swelling in your body as sudden weight gain is a symptom of congestion."
                countUnstability = countUnstability + 1
                symptomsToNurse.append(4)
                symptomEvaluation = symptomEvaluation + 1
                symptom1TodayAndYesterday = "Shortness of Breath levels have changed:\nYesterday: \(dyspneaAndContextYesterday).\nToday: \(dyspneaAndContextToday)."
                
                symptom1TodayAndYesterdayNurse = "- There seems to be worsening in the patient's breathlessness (Dyspnea).\nYesterday: \(dyspneaAndContextYesterday).\nToday: \(dyspneaAndContextToday).\nConsider uptitration of Diurectics until stabilization."
            }
            
            if degreeDyspnea == degreeDyspneaYesterday {
                symptom1Advice = "- Shortness of Breath\n\nYour shortness of breath seems to be controlled, only REMEMBER to take your medicine."
                symptom1TodayAndYesterdayNurse = "- Patient's breathlessness (Dyspnea) seems to be controlled."
            }
            
            if sleepPosition == "vertical" {
                symptomSleep = "Paroxysmal Nocturnal Dyspnea (Problem Sleeping)\n\nYou are experiencing WORSENING of heart failure and you might have woken up in the middle of the night and could not sleep layed down flat anymore, please REMEMBER to take your medicine, or else contact the Doctor very soon."
                countUnstability = countUnstability + 1
                symptomsToNurse.append(5)
                symptomEvaluation = symptomEvaluation + 1
                
                symptomSleepNurse = "- The patient presents episodes of Paroxysmal Nocturnal Dyspnea.\nConsider uptitration of Diurectics until stabilization."

            }
            

            if swollenBody != "No-Swollen" {
                symptomSwelling = "Body Swelling\n\nYou are experiencing swelling in your body, please REMEMBER to take your medicine, check your water and salt consumption, else contact your Doctor very soon."
                countUnstability = countUnstability + 1
                symptomsToNurse.append(6)
                symptomEvaluation = symptomEvaluation + 1
                
                symptomSwellingNurse = "- There are signs of decompensation and patient presents swelling in the body.\nConsider uptitration of Diuretics."

            }
            
            
            
            if cough == "Dry" {
                symptomCoughNurse = "- Patient presents Dry Coughing. Assess if there is presence of ACE-I allergy."
                symptomEvaluation = symptomEvaluation + 1

            }
            
            /* Ends Patient's and Nurse's Report */

            
            print("dyspnea: ", "today = ",degreeDyspnea, "yesterday = ", degreeDyspneaYesterday)
            patientOne.symptom1Advice = symptom1Advice
            patientOne.symptom1TodayAndYesterday = symptom1TodayAndYesterday
            patientOne.symptomSleep = symptomSleep
            patientOne.symptomSweeling = symptomSwelling
            
            
            patientOne.count = countUnstability
            
            let date = HelperFunctions.convertDateToString(NSDate())

            patientOne.date = date
            
            self.patientSample.append(patientOne)
            
            let username = self.dataService.getUserName()
            let userID = FIRAuth.auth()?.currentUser?.uid
            
            // symptom evaluation is used for determine patient unstability
            self.dataService.sendPatientAsUnstable(userID!, username: username, weight: weightEvaluation, bp: bpEvaluation, hr: hrEvaluation, numberOfSymptoms: symptomEvaluation, counter: countUnstability, date: date)
            
            self.dataService.sendPatientReportToNurse(userID!, username: username, weightValue: weightRecentMeasurement, weighValueAdvice: weightAdviceNurse, bloodPressureValue: recentSystolicBP, bloodPressureAdvice: bloodPressureAdviceNurse, heartRateValue: recentHeartRate, heartRateAdvice: heartRateAdviceNurse, symptomSwelling: symptomSwellingNurse, symptom1TodayAndYesterday: symptom1TodayAndYesterdayNurse, symptomSleep: symptomSleepNurse, symptomNausea: symptomNauseaNurse, symptomDizziness: symptomDizzinessNurse, symptomCough: symptomCoughNurse, counter: symptomEvaluation, date: date, diuretic: diuretic, ace_i: ace_i, beta_blocker: beta_blocker,  nurseConfirmation: nurseConfirmation)

            
//            dataService.sendMedicineToNurse(userID!, username: username, acei: ace_i, betablocker: beta_blocker, diuretic: diuretic, nurseConfirmation: nurseConfirmation, date: date)
            
            
            print("Patient illness level: ", countUnstability)
            print("Patient was feeling: ", degreeDyspneaYesterday, degreeDyspnea, degreeFatigue, degreeSymptom2, cough, swollenBody, sleepPosition)
            print("To Nurse array: ", symptomsToNurse)
            print("Date and Time of Patient analysis: ", date, patientSample[0].date )
            print(weightStability, systolicStability, heartRateStability)
            
            sendDataToSymptomsViewController()

        }
        

       
    }
    
    
    /* Symptoms from firebase */
    
    func symptomsFromDataBase() {
        let username = self.dataService.getUserName()
        dataService.fetchSymptoms(username, callback: populateSymptoms)
        dataService.fetchMedicine(username, callback: populateMedicine)
    }
    
    func populateSymptoms(symptoms: [SymptomsModel]) -> Void {
        self.symptomSamples = symptoms
        if self.symptomSamples.count > 0 {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let stringSymptoms = self.symptomSamples[0].date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let dateSymptoms = dateFormatter.dateFromString(stringSymptoms)!
                
                
                
                let clearCalendar = NSCalendar.currentCalendar()
                let clearTimeStart = clearCalendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())
                
                if (clearTimeStart!.compare(dateSymptoms) == .OrderedAscending) {
                    
                    self.checkSymptomsImage.image = UIImage(named: "checked")?.tintWithColor(self.filledColors)
                    self.symptomsAndSleepLabel.textColor =  UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0)
                    self.symptomsAndSleepLabel.text = "Good job, you answered the questions"
                    
                    self.confirmationSymptomsLabel.textColor = self.filledColorGray
                    self.confirmationSymptomsLabel.text = "Try it again tomorrow"
                    
                    let symptomsImage = UIImage(named: "feeling")
                    self.symptomsAndSleepImage.image = symptomsImage!.tintWithColor(UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0))
                    
                    print("- TODAY SYMPTOMS FIREBASE: ", self.symptomSamples[0].symptom1, self.symptomSamples[0].date)
                    
                    
                } else {
                    
                    self.checkSymptomsImage.image = UIImage(named: "unchecked")?.tintWithColor(self.filledColorGray)
                    self.symptomsAndSleepLabel.text = "Check your symptoms"
                    
                    self.confirmationSymptomsLabel.text = "Answer 5 questions"
                    
                    let symptomsImage = UIImage(named: "feeling")
                    self.symptomsAndSleepImage.image = symptomsImage!.tintWithColor(self.filledColorGray)
                    
                    print("- Symptoms Have changed to empty label")
                }
            })
            
        }
    }
    
    
    func populateMedicine(medicine: [Medicine]) -> Void {
        self.medicineSamples = medicine
        if self.medicineSamples.count > 0 {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let stringMedicine = self.medicineSamples[0].date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let dateMedicine = dateFormatter.dateFromString(stringMedicine)!
                
                
                
                let clearCalendar = NSCalendar.currentCalendar()
                let clearTimeStart = clearCalendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())
                
                if (clearTimeStart!.compare(dateMedicine) == .OrderedAscending) {
                    
                    
                    self.morningPillsLabel.text = self.medicineSamples[0].aceInhibitorType + "/" + self.medicineSamples[0].betaBlockerType + "/" + self.medicineSamples[0].diureticType + "/" + self.medicineSamples[0].mraType
                    
                    self.afternoonPillsLabel.text = self.medicineSamples[0].aceInhibitorType + "/" + self.medicineSamples[0].betaBlockerType + "/" + self.medicineSamples[0].diureticType + "/" + self.medicineSamples[0].mraType
                    
                    self.eveningPillsLabel.text = self.medicineSamples[0].aceInhibitorType + "/" + self.medicineSamples[0].betaBlockerType + "/" + self.medicineSamples[0].diureticType + "/" + self.medicineSamples[0].mraType
                    
                    print("- MEDICINES FROM FIREBASE: ", self.medicineSamples[0].aceInhibitorType + self.medicineSamples[0].betaBlockerType + self.medicineSamples[0].diureticType + self.medicineSamples[0].mraType, self.medicineSamples[0].date)
                    
                    
                } else {
                    
                  
                    
                    print("- MEDICINE HAS CHANGED TO EMPTY LABEL")
                }
            })
            
        }
    }

    
    /* Heart rates to Firebase (first time) */
    
    func heartRatesToFirebase() {
//        for bp in self.bloodPressureSamples {
//            print("- These are BP to compare with HR", bp.systolic, bp.diastolic, bp.date)
//        }
        
        var indexHeartRate = [Int]()
        let username = self.dataService.getUserName()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        
        FIRDatabase.database().reference().child("user-heartrates").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            
            guard snapshot.exists() else {
                print("Heart Rate Samples' counts", self.heartRateSamples.count)
                
                if self.bloodPressureSamples != [] && self.heartRateSamples != [] {
                    
                    for i in 0 ..< self.bloodPressureSamples.count {
                        let stringBloodPressureDate = self.bloodPressureSamples[i].date
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                        let dateBloodPressure = dateFormatter.dateFromString(stringBloodPressureDate)!
                        //let elapsedTime = NSDate().timeIntervalSinceDate(dateBloodPressure)
                        
                        for j in 0 ..< self.heartRateSamples.count {
                            let stringHeartRateDate = self.heartRateSamples[j].date
                            let dateHeartRate = dateFormatter.dateFromString(stringHeartRateDate)!
                            let differenceTime = dateHeartRate.timeIntervalSinceDate(dateBloodPressure)/3600
                            let valueHeartRate = self.heartRateSamples[j].measurement
                            if abs(differenceTime) < 0.05 {
                                print(i, j, valueHeartRate, "Dates: ", dateHeartRate, dateBloodPressure, differenceTime)
                                indexHeartRate.append(j)
                                
                                self.dataService.sendNewHeartRateToFireBase(userID!, username: username, measurement: self.heartRateSamples[j].measurement, date: self.heartRateSamples[j].date, sourceType: self.heartRateSamples[j].sourceType)
                                
                            }
                        }
                    }
                }
                return
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }

//        print("- Captured Indexes", indexHeartRate)
    }
    
    func updateHeartRate() {
        let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        healthManager.readAllSamples(sampleType!) { (allData, error) -> Void in
            if allData != [] {
                
                self.heartRateSamples = []
                
                for data in allData.reverse() {
                    
                    let heartRateOne = HeartRate()
                    
                    let heartRate = data as? HKQuantitySample
                    
                    //let date = String(mostRecentHeartRate.endDate)
                    let measurement = Float(heartRate!.quantity.doubleValueForUnit(HKUnit(fromString: "count/s"))*60)
                    let date = data.endDate as NSDate
                    let dateString = self.healthManager.getDateFormat(date)
                    let source = data.sourceRevision.source.name
                    heartRateOne.measurement = measurement
                    heartRateOne.date = dateString
                    heartRateOne.sourceType = source
                    self.heartRateSamples.append(heartRateOne)
                    //print("- Heart Rate: ", measurement, dateString, source)
                }
                
                // Heart Rate update Labels
                if self.heartRateSamples != [] {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        //self.heartRateSamples = self.heartRateSamples.reverse()
                        
                        let counterHeartRate = self.heartRateSamples.count - 1
                        
                        let stringHeartRateDate = self.heartRateSamples[counterHeartRate].date
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                        let dateHeartRate = dateFormatter.dateFromString(stringHeartRateDate)!
                        
                        let clearCalendar = NSCalendar.currentCalendar()
                        let clearTimeStart = clearCalendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())
                        
                        if (clearTimeStart!.compare(dateHeartRate) == .OrderedAscending) {
                            let heartRateTime = self.heartRateSamples[counterHeartRate].date.substringWithRange(self.heartRateSamples[counterHeartRate].date.startIndex.advancedBy(11) ..< self.heartRateSamples[counterHeartRate].date.startIndex.advancedBy(16))
                            
                            self.heartRateValueLabel.text = String(self.heartRateSamples[counterHeartRate].measurement) + "\nbpm"
                            self.heartRateTimeLabel.text = heartRateTime + "\nResting\nHeart Rate"
                            
                            self.heartRateValueLabel.textColor =  UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0)
                            let hearRateImageTimeLine = UIImage(named: "heart-512")
                            self.heartRateImage.image = hearRateImageTimeLine!.tintWithColor(UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0))
                            print("- TODAY HEART RATE: ", self.heartRateSamples[counterHeartRate].measurement, self.heartRateSamples[counterHeartRate].date)
                            
                        } else {
                            // Value 0 UNTIL A NEW WEIGHT IS ADDED
                            self.heartRateValueLabel.text = "--\nbpm"
                            self.heartRateTimeLabel.text = "\nNo\nvalue\nyet"
                            self.heartRateTimeLabel.text = ""
                            
                            let hearRateImageTimeLine = UIImage(named: "heart-512")
                            self.heartRateImage.image = hearRateImageTimeLine!.tintWithColor(self.filledColorGray)
                            print("- HR Have changed to empty label")
                        }
                    })
                    
                } else { print("No Actual Heart Rate data in Healthkit to print in TimeLine ") }

            }
        }
    }
    
    func updateWeight() {
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        healthManager.readAllSamples(sampleType!, completion: { (allData, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return
            }
            
            if allData != [] {
                
                self.weightsGroupedByDate = []
                self.newParameters = []
                
//                var weightTime =  ""
//                // 3. Format the weight to display it on the screen
//                self.weight = allData[0] as? HKQuantitySample
//                
//                // For weight time (important for keeping track)
//                let weightTimer = NSDateFormatter()
//                weightTimer.timeStyle = .ShortStyle
//                weightTime = weightTimer.stringFromDate(allData[0].startDate)
//                let dateString = self.healthManager.getDateFormat(allData[0].startDate)
//
//                
//                let measurement = self.weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
//                
//                print("- UpdateWeight Method: ", weightTime, measurement, dateString)
                
                
                // BEGINS CRAWL 60 (or ALL) DAYS DATA WEIGHT
                for data2 in allData {
                    let weight2 = data2 as? HKQuantitySample
                    //print("Weight other format \(weight2)")
                    
                    let measurement = String(weight2!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)))
                    let date = data2.endDate as NSDate
                    let dateString = self.healthManager.getDateFormat(date)
                    
                    let source = data2.sourceRevision.source.name
                    
                    
                    let parameters:[String:AnyObject] = [
                        "measurement": measurement,
                        "date": dateString,
                        "source": source
                    ]
                    
                    self.newParameters.append(parameters)
                }
                
                
                var averageSum: Float = 0
                var averageWeight: Float = 0
                
                for i in 0 ..< self.newParameters.count {
                    averageSum += self.newParameters[i]["measurement"]!!.floatValue
                    averageWeight = averageSum / Float(self.newParameters.count)
                }
                
                print("- Average weight", averageWeight)
                
                for i in 0 ..< self.newParameters.count { // for loop begins
                    let weightDataGrouped = Weight()
                    let dateParameter = String(self.newParameters[i]["date"]!!)
                    let weightParameter = self.newParameters[i]["measurement"]!!.floatValue
                    let weightSource = String(self.newParameters[i]["source"]!!)
                    
                    let dateFormatted = dateParameter.substringWithRange(dateParameter.startIndex.advancedBy(0) ..< dateParameter.startIndex.advancedBy(10))
                    
                    // TAKE VALUES ONLY WHEN AVERAGE WEIGHT AND ACTUAL WEIGHT IS < THAN 5 TO AVOID BIG OUTLIERS PAST 7 DAYS
                    // fix for crawling 60 days values
                    if abs(averageWeight-weightParameter) < 5 {
                        
                        if i == self.newParameters.count-1 {
                            weightDataGrouped.measurement = weightParameter
                            weightDataGrouped.date = dateParameter
                            weightDataGrouped.sourceType = weightSource
                            self.weightsGroupedByDate.append(weightDataGrouped)
                            break
                        }
                        
                        let nextDateParameter = String(self.newParameters[i+1]["date"]!!)
                        let nextDateFormatted = nextDateParameter.substringWithRange(nextDateParameter.startIndex.advancedBy(0) ..< nextDateParameter.startIndex.advancedBy(10))
                        
                        if dateFormatted != nextDateFormatted {
                            weightDataGrouped.measurement = weightParameter
                            weightDataGrouped.date = dateParameter
                            weightDataGrouped.sourceType = weightSource
                            self.weightsGroupedByDate.append(weightDataGrouped)
                            //print("Dates parameters 1:", dateParameter, nextDateParameter)
                        }
                        else { // for first measure, catches the latest good measure of TODAY
                            if i == 0 && (dateFormatted != nextDateFormatted) {
                                weightDataGrouped.measurement = weightParameter
                                weightDataGrouped.date = dateParameter // MAYBE COULD SOLVE MULTIPLE
                                weightDataGrouped.sourceType = weightSource
                                self.weightsGroupedByDate.append(weightDataGrouped)
                                //print("Dates parameters 2:", dateParameter, nextDateParameter)

                            }
                        }
                    }
                }
                
//                for wgbd in self.weightsGroupedByDate {
//                    
//                    print("\nWeight groups by date: \(wgbd.measurement) \(wgbd.date) \(wgbd.sourceType)")
//                }
                
                let username = self.dataService.getUserName()
                //let userId = self.dataService.getUserID()
                let userID = FIRAuth.auth()?.currentUser?.uid
                
                
                // observe if data base exists with crawled values for the user
                
                self.refTimeLine.child("user-weights").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    // Get user value
                    
                    guard snapshot.exists() else {
                        
                        self.weightsGroupedByDate = self.weightsGroupedByDate.reverse()

                        for wgbd in self.weightsGroupedByDate {
                            
                            self.dataService.sendNewWeightToFireBase(userID!, username: username, measurement: wgbd.measurement, date: wgbd.date, sourceType: wgbd.sourceType)
                            
                            print("\nWeight groups by date: \(wgbd.measurement) \(wgbd.date) \(wgbd.sourceType)")
                        }
                        return
                    }
                    
                    
                }) { (error) in
                    print(error.localizedDescription)
                }

                // Weight Update Labels
                if self.weightsGroupedByDate.count > 0  {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        //self.weightsGroupedByDate = self.weightsGroupedByDate.reverse()
                        //let counter = self.weightsGroupedByDate.count - 1
                        let stringWeightDate = self.weightsGroupedByDate[0].date
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                        let dateWeight = dateFormatter.dateFromString(stringWeightDate)!
                        
                        
                        let clearCalendar = NSCalendar.currentCalendar()
                        let clearTimeStart = clearCalendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())
                        
                        //print("Reset Time: ", clearTimeStart!, "  Now:", NSDate(), " Weight Time: ", dateWeight)
                        
                        
                        if (clearTimeStart!.compare(dateWeight) == .OrderedAscending) {
                            
                            let weightTime = self.weightsGroupedByDate[0].date.substringWithRange(self.weightsGroupedByDate[0].date.startIndex.advancedBy(11) ..< self.weightsGroupedByDate[0].date.startIndex.advancedBy(16))
                            
                            
                            self.weightValueLabel.text = String(self.weightsGroupedByDate[0].measurement) + " kg " + "at " + weightTime
                            self.checkWeightImage.image = UIImage(named: "checked")?.tintWithColor(self.filledColors)
                            self.weightValueLabel.textColor =  UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0)
                            
                            
                            let weightImageTimeLine = UIImage(named: "weight")
                            self.weightImage.image = weightImageTimeLine!.tintWithColor(UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0))
                            
                            print("- TODAY WEIGHT: ", self.weightsGroupedByDate[0].date, self.weightsGroupedByDate[0].measurement)

                            
                        } else {
                            // Value 0 UNTIL A NEW WEIGHT IS ADDED
                            self.weightValueLabel.text = "Check Weight before breakfast"
                            self.checkWeightImage.image = UIImage(named: "unchecked")
                            let weightImageTimeLine = UIImage(named: "weight")
                            self.weightImage.image = weightImageTimeLine!.tintWithColor(self.filledColorGray)
                            let weightCheckTimeLine = UIImage(named: "unchecked")
                            self.checkWeightImage.image = weightCheckTimeLine?.tintWithColor(self.filledColorGray)
                            print("- Weight Have changed to empty label")
                            
                        }
                        
                        
                    })
                } else { print("No Actual Weight data in Healthkit to print in TimeLine ")}
            
            }
        })
        
    }
    
    
    
    func readSampleByBloodPressure()
    {
        guard let type = HKQuantityType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure),
            let systolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic),
            let diastolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic) else {
                // display error, etc...
                return
        }
        
        let startDate = NSDate.distantPast()
        let endDate   = NSDate()
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            
            //var bloodTime =  "xxxxxx"
            
            //self.bloodPressureSamples = []
            
            if let dataList = results as? [HKCorrelation]  {
                //print("- These are blood pressure samples in array: ", dataList )

                for data in dataList.reverse()
                {
                    let bloodPressureOne = BloodPressure()

                    if let data1 = data.objectsForType(systolicType).first as? HKQuantitySample,
                        let data2 = data.objectsForType(diastolicType).first as? HKQuantitySample {
                        

                        let value1 = data1.quantity.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                        let value2 = data2.quantity.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                        
//                        let bloodTimer = NSDateFormatter()
//                        bloodTimer.timeStyle = .ShortStyle
//                        bloodTime = bloodTimer.stringFromDate(data.startDate)
                        
                        
                        bloodPressureOne.systolic = Float(value1)
                        bloodPressureOne.diastolic = Float(value2)
                        bloodPressureOne.date = self.healthManager.getDateFormat(data1.startDate)
                        bloodPressureOne.sourceType = String(data1.sourceRevision.source.name)
                        self.bloodPressureSamples.append(bloodPressureOne)

                        //print("S: ", value1, "D: ", " Date: ", value2, bloodPressureOne.date)
                    }
                }
                
                let username = self.dataService.getUserName()
                let userID = FIRAuth.auth()?.currentUser?.uid
                //self.bloodPressureSamples = self.bloodPressureSamples.reverse()
                
                // observe if data base exists with crawled values for the user
                
                self.refTimeLine.child("user-bps").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    // Get user value
                    
                    guard snapshot.exists() else {
                        
                        for bps in self.bloodPressureSamples {
                            
                            self.dataService.sendNewBloodPressureToFireBase(userID!, username: username, systolic: bps.systolic, diastolic: bps.diastolic, date: bps.date, sourceType: bps.sourceType)
                            print("BPS from Timeline: ", bps.systolic, bps.diastolic, bps.date, bps.sourceType)
                        }
                        return
                    }
                    
                    //print("- Firebase weights history", snapshot.value!)
                    
                }) { (error) in
                    print(error.localizedDescription)
                }

                
                if self.bloodPressureSamples != [] {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        //                for bps in self.bloodPressureSamples {
                        //                    print("- BPs Testing", bps.diastolic, bps.systolic, bps.date)
                        //                }
                        
                        //self.bloodPressureSamples = self.bloodPressureSamples.reverse()
                        let counterBloodPressure = self.bloodPressureSamples.count - 1
                        let stringBloodPressureDate = self.bloodPressureSamples[counterBloodPressure].date
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                        let dateBloodPressure = dateFormatter.dateFromString(stringBloodPressureDate)!
                        
                        let clearCalendar = NSCalendar.currentCalendar()
                        let clearTimeStart = clearCalendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())
                        
                        var bloodTime = ""
                        
                        if (clearTimeStart!.compare(dateBloodPressure) == .OrderedAscending) {
                            
                            let bloodTimer = NSDateFormatter()
                            bloodTimer.timeStyle = .ShortStyle
                            bloodTime = bloodTimer.stringFromDate(dateBloodPressure)
                            
                            self.bloodPressureValueLabel.text = String("S: \(self.bloodPressureSamples[counterBloodPressure].systolic) / D: \(self.bloodPressureSamples[counterBloodPressure].diastolic) mm Hg at \(bloodTime)")
                            
                            self.checkBloodPImage.image = UIImage(named: "checked")?.tintWithColor(self.filledColors)
                            self.bloodPressureValueLabel.textColor =  UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0)
                            
                            
                            let bpImageTimeLine = UIImage(named: "blood2")
                            self.bloodPressureImage.image = bpImageTimeLine!.tintWithColor(UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0))
                            
                            print("- TODAY BLOOD PRESSURE: ",self.bloodPressureSamples[counterBloodPressure].date, self.bloodPressureSamples[counterBloodPressure].systolic, self.bloodPressureSamples[counterBloodPressure].diastolic)

                            
                            
                        } else {
                            // Value 0 UNTIL A NEW WEIGHT IS ADDED
                            self.bloodPressureValueLabel.text = "Check Blood Pressure before breakfast"
                            self.checkBloodPImage.image = UIImage(named: "unchecked")
                            
                            let bpImageTimeLine = UIImage(named: "blood2")
                            self.bloodPressureImage.image = bpImageTimeLine!.tintWithColor(self.filledColorGray)
                            let bpCheckTimeLine = UIImage(named: "unchecked")
                            self.checkBloodPImage.image = bpCheckTimeLine?.tintWithColor(self.filledColorGray)
                            
                            print("- BP Have changed to empty label")
                        }
                        
                        
                    })
                    
                } else { print("No Actual Blood Pressure data in Healthkit to print in TimeLine ") }

            }
        }
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            print("- XXXXXXX NUMBER 3")
            showSurvey()
//            let taskViewController = ORKTaskViewController(task: TestSymptoms(), taskRunUUID: NSUUID())
//            taskViewController.delegate = self
//            
//            presentViewController(taskViewController, animated: true, completion: nil)
        }
    }

}

extension TimeLineTableViewController: ORKTaskViewControllerDelegate {
    
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
        
        var symptoms1 = ""
        var context1 = ""
        var symptoms2 = ""
        var frequency1 = ""
        var symptoms3 = ""
        var symptoms4 = ""
        var symptoms5 = ""

        let taskResult = taskViewController.result
        
        if taskResult != [] {
            
            if let symptomsPart1 = taskResult.stepResultForStepIdentifier("symptoms_part1")?.resultForIdentifier("symptoms1") as? ORKChoiceQuestionResult {
                
                if symptomsPart1.choiceAnswers != nil {
                    symptoms1 = String(symptomsPart1.choiceAnswers![0])
                    
                }

                
            }
            
            
            if let symptomsContext = taskResult.stepResultForStepIdentifier("symptoms_part1")?.resultForIdentifier("symptomsContext") as? ORKChoiceQuestionResult {
                if symptomsContext.choiceAnswers != nil {
                    context1 = String(symptomsContext.choiceAnswers![0])
                    
                }
                
                print("Symptoms part 1: ", symptoms1, "/ Context: ", context1)
            }
            
            
            
            
            if let symptomsPart2 = taskResult.stepResultForStepIdentifier("symptoms_part2")?.resultForIdentifier("symptoms2") as? ORKChoiceQuestionResult {
                if symptomsPart2.choiceAnswers != nil {
                    symptoms2 = String(symptomsPart2.choiceAnswers![0])
                    
                }
            }
            
            
            
            if let symptomsFrequency = taskResult.stepResultForStepIdentifier("symptoms_part2")?.resultForIdentifier("symptomsFrequency") as? ORKChoiceQuestionResult {
                
                if symptomsFrequency.choiceAnswers != nil {
                    frequency1 = String(symptomsFrequency.choiceAnswers![0])
                    print("Symptoms part 2: ", symptoms2, "/ Frequency: ", frequency1)

                    
                }
            }
            
            
            
            
            if let symptomsPart3 = taskResult.stepResultForStepIdentifier("symptoms_part3")?.resultForIdentifier("symptoms3") as? ORKChoiceQuestionResult {
                if symptomsPart3.choiceAnswers != nil {
                    symptoms3 = String(symptomsPart3.choiceAnswers![0])
                }

                
            }
            
            
            if let symptomsPart4 = taskResult.stepResultForStepIdentifier("symptoms_part4")?.resultForIdentifier("symptoms4") as? ORKChoiceQuestionResult {
                if symptomsPart4.choiceAnswers != nil {
                    symptoms4 = String(symptomsPart4.choiceAnswers![0])
                }
                
            }
            
           
            
            if let symptomsPart5 = taskResult.stepResultForStepIdentifier("symptoms_part5")?.resultForIdentifier("symptoms5") as? ORKChoiceQuestionResult {
                
                if symptomsPart5.choiceAnswers != nil {
                    symptoms5 = String(symptomsPart5.choiceAnswers![0])
                    
                    
                    self.checkSymptomsImage.image = UIImage(named: "checked")?.tintWithColor(self.filledColors)
                    self.symptomsAndSleepLabel.textColor =  UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0)
                    self.symptomsAndSleepLabel.text = "Good job, you answered the questions"
                    
                    self.confirmationSymptomsLabel.textColor = filledColorGray
                    self.confirmationSymptomsLabel.text = "See your Evaluation"
                    
                    let symptomsImage = UIImage(named: "feeling")
                    self.symptomsAndSleepImage.image = symptomsImage!.tintWithColor(UIColor(red: 6/255, green: 122/255, blue: 255/255, alpha: 1.0))
                    
                    
                }
                
                print("Symptoms part 3: ", symptoms3)
                
                print("Symptoms part 4: ", symptoms4)
                
                print("Symptoms part 5: ", symptoms5)
                
                let date = self.healthManager.getDateFormat(taskResult.endDate!)
                
                print("symptoms date: ", date)
                
                let username = self.dataService.getUserName()
                let userID = FIRAuth.auth()?.currentUser?.uid
                
                self.dataService.sendNewSymptomsToFireBase(userID!, username: username, symptom1: symptoms1, symptom1Context: context1, symptom2: symptoms2, symptom2Frequency: frequency1, symptom3: symptoms3, symptom4: symptoms4, symptom5: symptoms5, date: String(date))
            }
            
            
            
        }

        
        taskViewController.dismissViewControllerAnimated(true, completion: nil)

    }
}
