//
//  SymptomsTableViewController.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit

class SymptomsTableViewController: UITableViewController {
    
    var patientSample = [SummaryPatient]()
    var patientSymptoms = [SymptomsModel]()
    
    var patientWeights = [Weight]()
    var patientBPs = [BloodPressure]()
    var patientHRs = [HeartRate]()
    
    
    @IBOutlet weak var summaryText: UITextView!

    @IBOutlet weak var symptomsText: UITextView!
    
    @IBOutlet weak var measurementsText: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //summarySymptoms()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        summarySymptoms()

    }
    
    func summarySymptoms() {
        
        //print("Patient Sample counter: ", patientSample.count, patientSample[0].date, self.patientWeights[0].date, self.patientBPs[0].date, self.patientHRs[0].date)
        //self.patientSample = self.patientSample.reverse()
        //self.patientSymptoms = self.patientSymptoms.reverse()
        
        if patientSample.count > 0 {
            
            
            let symptom1TodayAndYesterday = patientSample[0].symptom1TodayAndYesterday
            let symptom1Advice = patientSample[0].symptom1Advice
            let symptomSweeling = patientSample[0].symptomSweeling
            let symptomSleep = patientSample[0].symptomSleep
            
            print("- ******** symptoms view controller: ",symptom1Advice, symptomSweeling, symptom1TodayAndYesterday, symptomSleep)

            let date = patientSample[0].date
            
            self.summaryText.text = "Updated: " + date + "\n\n" + "Not enough data today to assess your condition."
            
            self.symptomsText.text = "You have not checked the questionnaire of Today. \n\nPlease remember to submit your symptoms.\n\nSymptoms are important metrics to assess your health and to provide proper insights, both might help you understand Heart Failure and to control symptoms."
            
            self.measurementsText.text = "Please remember to measure your weight, blood pressure and heart rate. Those values help the app to validate your daily assessment and provide better feedback."
          

            
            if self.patientSymptoms.count > 0 && self.patientWeights.count > 0 && self.patientBPs.count > 0 && self.patientHRs.count > 0 {
                
                let todayString = HelperFunctions.convertDateToShortString(NSDate())
                
                let dateSymptomShorter = HelperFunctions.shortString(self.patientSymptoms[0].date)
                let dateWeightShorter = HelperFunctions.shortString(self.patientWeights[0].date)
                let dateBloodPressureShorter = HelperFunctions.shortString(self.patientBPs[0].date)
                let dateHeartRateShorter = HelperFunctions.shortString(self.patientHRs[self.patientHRs.count-1].date)
                
                print("printing data: ", dateSymptomShorter, dateWeightShorter, dateBloodPressureShorter, dateHeartRateShorter, todayString, self.patientSample[0].count)
                
                
                if  self.patientSample[0].count == 0 && todayString == dateSymptomShorter {
                    
                     self.summaryText.text = "Updated: " + date + "\n\n" + "Good Job!\nYour condition today is excellent, keep the good work!"
                    
                    self.symptomsText.text = "Recommendations:\nIt seems you have no new worsening symptoms. However, remember to control your fluid intake and salt consumption as these two may lead to sweeling in your body. \n\nAlso, remember to take your medicine everyday and if you have side effects such as feeling dizziness, nausea, lack of apettite or fatigue, submit them in the symptom's questionnaire. \n\nThe main goal of the treatment is to keep your symptoms controlled, do not forget to complete your activites for providing you of an assessment."
                    
//                    self.measurementsText.text = "Recommendations:\nIt seems your weight, blood pressure and heart rate are within a normal range. REMEMBER to take your medicine as prescribed by the Doctor. Medicine adherance is very important to lower risks of decompensation and worsening of your health."
                    
                }
                
                if self.patientSample[0].count > 0 {
                    
                    self.summaryText.text = "Updated: " + date + "\n\n" + "The app has evaluated \(self.patientSample[0].count) situation(s). It is therefore advisable to look carefully the summaries below."
                    self.symptomsText.text = symptom1Advice + "\n" + symptom1TodayAndYesterday + "\n\n"  + symptomSleep + "\n\n"  + symptomSweeling
                    //self.measurementsText.text = weightAdvice + "\n\n"  + bloodPressureAdvice + "\n\n"  + heartRateAdvice
                
                }
                
                if todayString != dateSymptomShorter {
                    
                    self.summaryText.text = "Updated: " + date + "\n\n" + "Not enough data today to assess your condition."
                    
                    self.symptomsText.text = "You have not checked the questionnaire of Today. \n\nPlease remember to submit your symptoms.\n\nSymptoms are important metrics to assess your health and to provide proper insights, both might help you understand Heart Failure and to control symptoms."
                }
                
            }
        
            
        }
        
        if  self.patientWeights.count > 0 && self.patientBPs.count > 0 && self.patientHRs.count > 0 {
            print("**** TRUE ********")
            let todayString = HelperFunctions.convertDateToShortString(NSDate())
            
            let dateWeightShorter = HelperFunctions.shortString(self.patientWeights[0].date)
            let dateBloodPressureShorter = HelperFunctions.shortString(self.patientBPs[0].date)
            let dateHeartRateShorter = HelperFunctions.shortString(self.patientHRs[self.patientHRs.count-1].date)
            
            let weightAdvice = String(patientSample[0].weightAdvice)
            let bloodPressureAdvice = patientSample[0].bloodPressureAdvice
            let heartRateAdvice = patientSample[0].heartRateAdvice
            
            
            if dateWeightShorter == todayString || dateBloodPressureShorter == todayString || dateHeartRateShorter == todayString {
                
                self.measurementsText.text = weightAdvice + "\n\n"  + bloodPressureAdvice + "\n\n"  + heartRateAdvice
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 
}
