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
    
    var userSelected = User()
    var patientSelected = SummaryPatient()
    
    var patientName = ""
    var patientUid = ""
    
    
    var aceName = "select here  -- >"
    var betaBlockerName = "Select here   -- >"
    var diureticName = "select here  -- >"
    var arbName = "select here  -- >"
    var mraName = "select here  -- >"

    
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
            print("- USER FROM MEDICATION: ", user.userName, user.uid)
            
        } else
            
            if let patient = self.detailPatient {
                self.navigationItem.title = patient.userName
                self.patientSelected = patient
                patientName = patient.userName
                patientUid = patient.uid

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
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func sendDataToPatient(sender: AnyObject) {
        
        
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

            
        } else {
            print("PATIENT NOT SELECTED")
        }

        
        
    }
    
}
