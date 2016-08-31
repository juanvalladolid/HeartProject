//
//  SymptomsViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 19/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit

class SymptomsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    
    let dataService = FirebaseService()


    var userSelected = User()
    var patientUnstable = SummaryPatient()
    
    var summaryToNurseSamples = [SummaryToNurse]()
   // var weights = [Weight]()

    
    @IBOutlet weak var testingLabel: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    var detailItem: User? {
        didSet {
            // Update the view.
           // self.configureView()
        }
    }
    

    
    var detailPatient: SummaryPatient? {
        didSet {
            //self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        //self.navigationItem.title = "hello"
        
        if detailItem != nil {
            if let user = self.detailItem {
                

                self.navigationItem.title = user.userName
                self.userSelected = user
                
                dataService.fetchSummaryToNurse(user.userName, callback: populateSummaryToNurse)
                

                print("PATIENT NORMAL", user.userName)
            }

        }
        
        if detailPatient != nil {
            if let user = self.detailPatient {
                

                self.navigationItem.title = user.userName
                self.patientUnstable = user
                

                dataService.fetchSummaryToNurse(user.userName, callback: populateSummaryToNurse)
                
                print("PATIENT UNSTABLE ", user.userName, "UID: ", user.uid)


            }
            
        }
        
    }
    
    func populateSummaryToNurse(summary: [SummaryToNurse]) -> Void {
        
        myActivityIndicator.startAnimating()

        
        self.summaryToNurseSamples = summary
        
        for i in self.summaryToNurseSamples {
            print("**** SUMMARY TO NURSE: ", i.date, i.symptom1TodayAndYesterday, i.count)

        }
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            
            if self.summaryToNurseSamples != [] {
                self.testingLabel.text = "Updated: " + self.summaryToNurseSamples[0].date
                //self.testingLabel.text = "Updated: date xxxx "

            } else {
                self.testingLabel.text = "Patient has not updated new data"

            }
            

            self.myTableView.reloadData()
            
            self.myActivityIndicator.stopAnimating()

        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationItem.title = "testing"

        
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()

        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        self.configureView()
        //navigationItem.title = "hello2"

        
        if detailItem != nil {
            let tabBar = self.tabBarController
            let navBar = tabBar!.viewControllers![1] as! UINavigationController
            
            //navigationItem.title = "hello3"

            
            let svc = navBar.topViewController as! ChartTableViewController
            svc.detailItem = self.detailItem
            
            svc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            svc.navigationItem.leftItemsSupplementBackButton = true


            let navBar2 = tabBar!.viewControllers![2] as! UINavigationController

            let svc2 = navBar2.topViewController as! MedicationTableViewController
            svc2.detailItem = self.detailItem
            
            svc2.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            svc2.navigationItem.leftItemsSupplementBackButton = true
            
        }
        
        
        if detailPatient != nil {
            let tabBar = self.tabBarController
            
            let navBar = tabBar!.viewControllers![1] as! UINavigationController
            
            let svc = navBar.topViewController as! ChartTableViewController
            svc.detailPatient = self.detailPatient
            
            svc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            svc.navigationItem.leftItemsSupplementBackButton = true
            
            let navBar2 = tabBar!.viewControllers![2] as! UINavigationController
            let svc2 = navBar2.topViewController as! MedicationTableViewController
            svc2.detailPatient = self.detailPatient
            
            svc2.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            svc2.navigationItem.leftItemsSupplementBackButton = true
            
        }

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let myCell = tableView.dequeueReusableCellWithIdentifier("evaluationCell", forIndexPath: indexPath) as! EvaluationTableViewCell
        
        


        if self.summaryToNurseSamples != [] {
            
            let todayString = HelperFunctions.convertDateToShortString(NSDate())
            let arrayDate = HelperFunctions.shortString(self.summaryToNurseSamples[0].date)
            
            print(todayString, arrayDate)
            
            if arrayDate == todayString {
                
                myCell.textEvaluationView.text = "The patient presents \(self.summaryToNurseSamples[0].count) situation(s) according to the symptoms and measurements from Today: " + "\n\n"
                    + self.summaryToNurseSamples[0].symptom1TodayAndYesterday + "\n\n"
                    + self.summaryToNurseSamples[0].symptomSleep + "\n\n"
                    + self.summaryToNurseSamples[0].symptomSwelling + "\n\n"
                    + self.summaryToNurseSamples[0].symptomNausea + "\n\n"
                    + self.summaryToNurseSamples[0].symptomCough + "\n\n"
                    + self.summaryToNurseSamples[0].weightAdvice + "\n\n"
                    + self.summaryToNurseSamples[0].bloodPressureAdvice + "\n\n"
                    + self.summaryToNurseSamples[0].heartRateAdvice
                
            } else {
                
                myCell.textEvaluationView.text = "Patient has not updated new data"

            }
            
            
        }
        
        
        return myCell
    }
    
    


    
}
