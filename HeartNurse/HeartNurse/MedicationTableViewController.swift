//
//  MedicationTableViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 25/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import Firebase

class MedicationTableViewController: UITableViewController, ACETableViewControllerDelegate, BetaBlockerTableViewControllerDelegate, DiureticTableViewControllerDelegate, ARBTableViewControllerDelegate, MRATableViewControllerDelegate {
    
    let dataService = FirebaseService()
    
    @IBOutlet weak var medicineActivityIndicator: UIActivityIndicatorView!
    var summaryToNurseSamples = [SummaryToNurse]()
    
    @IBOutlet weak var aceType: UILabel!
    @IBOutlet weak var aceDose: UITextField!
    @IBOutlet weak var aceTimesADay: UITextField!
    
    
    @IBOutlet weak var betaBlockerType: UILabel!
    @IBOutlet weak var betaBlockerDose: UITextField!
    @IBOutlet weak var betaBlockerTimesADay: UITextField!
    
    
    @IBOutlet weak var diureticType: UILabel!
    @IBOutlet weak var diureticDose: UITextField!
    @IBOutlet weak var diureticTimesADay: UITextField!
    
    
    @IBOutlet weak var arbType: UILabel!
    @IBOutlet weak var arbTimesADay: UITextField!
    @IBOutlet weak var arbDose: UITextField!
    
    
    @IBOutlet weak var mraType: UILabel!
    @IBOutlet weak var mraDose: UITextField!
    @IBOutlet weak var mraTimesADay: UITextField!
    
    
    @IBOutlet weak var suggestedMedicineTextView: UITextView!
    
    
    var userSelected = User()
    var patientSelected = SummaryPatient()
    
    var patientName = ""
    var patientUid = ""
    
    
    var aceName = ""
    var betaBlockerName = ""
    var diureticName = ""
    var arbName = ""
    var mraName = ""
    var didPickMany = ""
    
    var ace_i = ""
    var beta_blocker = ""
    var diuretic = ""

    
    
    var detailPatient: SummaryPatient? {
        didSet {
            
        }
    }
    
    var detailItem: User? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let user = self.detailItem {
            self.navigationItem.title = user.userName
            self.userSelected = user
            patientName = user.userName
            patientUid = user.uid
            dataService.fetchSummaryToNurse(user.userName, callback: populateSummaryToNurse)

            print("- USER FROM MEDICATION: ", user.userName, user.uid)
            
        } else
            
            if let patient = self.detailPatient {
                self.navigationItem.title = patient.userName
                self.patientSelected = patient
                patientName = patient.userName
                patientUid = patient.uid
                
                dataService.fetchSummaryToNurse(patient.userName, callback: populateSummaryToNurse)

                print("- USER FROM MEDICATION: ", patient.userName, patient.uid)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
//        aceType.text = aceName
//        betaBlockerType.text = betaBlockerName
//        diureticType.text = diureticName
//        arbType.text = arbName
//        mraType.text = mraName
        
        let tapper = UITapGestureRecognizer(target: view, action:#selector(UIView.endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)

        
    }
    
    func populateSummaryToNurse(summary: [SummaryToNurse]) -> Void {
        
        //myActivityIndicator.startAnimating()
        
        
        self.summaryToNurseSamples = summary
        
        for i in self.summaryToNurseSamples {
            print("**** MEDICINE FROM SUMMARY: ", i.date, i.ace_i, i.beta_blocker)
            
        }
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            
            if self.summaryToNurseSamples != [] {
                
                if self.summaryToNurseSamples[0].ace_i == 1 {
                    self.ace_i = "Increase ACE-I dosage"
                    print("ACE MEDICINE = ", self.ace_i)
                    
                } else if  self.summaryToNurseSamples[0].ace_i == -1 {
                    self.ace_i = "Decrease ACE-I dosage"
                    print("ACE MEDICINE = ", self.ace_i)

                }
                
                
                if self.summaryToNurseSamples[0].beta_blocker == 1 {
                    self.beta_blocker = "Increase Beta blocker dosage"
                    
                } else if self.summaryToNurseSamples[0].beta_blocker == -1 {
                    self.beta_blocker = "Decrease Beta blocker dosage"
                }
                
                if self.summaryToNurseSamples[0].diuretic == 1 {
                    self.diuretic = "Increase Diuretic dosage"
                    
                } else if self.summaryToNurseSamples[0].diuretic == -1 {
                    self.diuretic = "Decrease Diuretic dosage"}
                
                if self.ace_i != ""  ||  self.beta_blocker != ""  ||  self.diuretic != "" {
                    
                    self.suggestedMedicineTextView.text = "Based on symptoms and objective data from the patient, the system recommends the following medication update:\n\n"
                        + self.ace_i + "\n" + self.beta_blocker + "\n" + self.diuretic 
                    
                } else {
                    self.suggestedMedicineTextView.text = "No new medicine recommendations yet."
                }
                
            } else {
                
                self.suggestedMedicineTextView.text = "The patient has not send enough data yet."

            }
            
            //self.myActivityIndicator.stopAnimating()
            
        }
        
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toACE" {
            let controller = segue.destinationViewController as! ACETableViewController
            controller.delegate = self
            
            controller.navigationItem.title = "Angiotensin-converting Enzyme "

        }
        
        if segue.identifier == "toBetaBlocker" {
            let controller = segue.destinationViewController as! BetaBlockerTableViewController
            controller.delegate = self
        }
        
        if segue.identifier == "toDiuretic" {
            let controller = segue.destinationViewController as! DiureticTableViewController
            controller.delegate = self
        }
        
        if segue.identifier == "toARB1" {
            let controller = segue.destinationViewController as! ARBTableViewController
            controller.delegate = self
        }
        
        if segue.identifier == "toMRA1" {
            let controller = segue.destinationViewController as! MRATableViewController
            controller.delegate = self
        }

    }

    func acePicker(picker: ACETableViewController, didPickName aceName: String) {
        self.aceName = aceName
        aceType.text = aceName
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func betaBlockerPicker(picker: BetaBlockerTableViewController, didPickName betaBlockerName: String) {
        self.betaBlockerName = betaBlockerName
        betaBlockerType.text = betaBlockerName
        navigationController?.popViewControllerAnimated(true)

    }
    
    func diureticPicker(picker: DiureticTableViewController, didPickName diureticName: String) {
        self.diureticName = diureticName
        diureticType.text = diureticName
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    func arbPicker(picker: ARBTableViewController, didPickName arbName: String) {
        self.arbName = arbName
        arbType.text = arbName
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    func mraPicker(picker: MRATableViewController, didPickName arbName: String) {
        self.mraName = arbName
        mraType.text = arbName
        
//        for i in didPickMany {
//            print(didPickMany, i)
//        }
//        
        //mraType.text =
       // navigationController?.popViewControllerAnimated(true)
        
    }
    

    
    @IBAction func sendDataToPatient(sender: AnyObject) {
        
        self.medicineActivityIndicator.startAnimating()
        
        let aceDose = self.aceDose.text
        let aceTimesADay = self.aceTimesADay.text
        
        let betaDose = self.betaBlockerDose.text
        let betaTimesADay = self.betaBlockerTimesADay.text
        
        let diureticDose = self.diureticDose.text
        let diureticTimesADay = self.diureticTimesADay.text
        
        let arbDose = self.arbDose.text
        let arbTimesADay = self.arbTimesADay.text
        
        let mraDose = self.mraDose.text
        let mraTimesADay = self.mraTimesADay.text
        
        let date = HelperFunctions.convertDateToString(NSDate())
        
      
        let userID = patientUid
        
        if userID != "" {
            
            self.dataService.sendMedicineFromNurseTo(userID, username: patientName, date: date,
                                                     aceInhibitorType: aceName, aceInhibitorDose: aceDose!, aceInhibitorTimes: aceTimesADay!,
                                                     
                                                     betaBlockerType: betaBlockerName, betaBlockerDose: betaDose!, betaBlockerTimes: betaTimesADay!,
                                                     
                                                     diureticType: diureticName, diureticDose: diureticDose!, diureticTimes: diureticTimesADay!,
                                                     
                                                     arbType: arbName, arbDose: arbDose!, arbTimesADay: arbTimesADay!,
                                                     
                                                     mraType: mraName, mraDose: mraDose!, mraTimesADay: mraTimesADay! )
            
            print("** Medicine: ", userID, aceDose!, aceTimesADay!, betaDose!, betaTimesADay!)
            
            self.suggestedMedicineTextView.text = "\n\n\nThe new prescription has been sent to the patient"
            self.suggestedMedicineTextView.textColor = UIColor.blueColor()

            self.medicineActivityIndicator.stopAnimating()
            
            tableView.setContentOffset(CGPointZero, animated:true)


            
        } else {
            print("PATIENT NOT SELECTED")
            
            self.suggestedMedicineTextView.text = "\n\n\nFirst, you need to select a patient"
            
            self.medicineActivityIndicator.stopAnimating()
            
            tableView.setContentOffset(CGPointZero, animated:true)



        }

        
        
    }
    
}
