//
//  NewMasterViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 22/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit

class NewMasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate {
    
    
    private var collapseDetailViewController = true

    @IBOutlet weak var mySegmentedController: UISegmentedControl!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myTableView: UITableView!
    

    
    var chartTableViewController: ChartTableViewController? = nil
    
    var symptomsTableViewController: SymptomsViewController? = nil
    
    let dataService = FirebaseService()
    var fetchedUser = [User]()
    var unstableUser = [SummaryPatient]()
    var stableUser = [SummaryPatient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryOverlay
        //self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
        


        print("- Master: view did load")
        dataService.FirebaseLogIn("admin@test.com", password: "password1")
        dataService.fetchUsers(populateFetchedUsers)
        dataService.fetchUnstablePatient(populateUnstableUSers)
        dataService.fetchStablePatient(populateStableUSers)
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            let tabController = controllers[controllers.count-1] as! UITabBarController
            let navController = tabController.viewControllers?.first as! UINavigationController
            self.symptomsTableViewController = navController.topViewController as? SymptomsViewController
        }
        
        splitViewController?.delegate = self

    
    }
    

    
    override func viewWillAppear(animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        self.fetchedUser = []

        dataService.fetchUsers(populateFetchedUsers)
        dataService.fetchUnstablePatient(populateUnstableUSers)
        dataService.fetchStablePatient(populateStableUSers)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateUnstableUSers(users:[SummaryPatient]) {
        myActivityIndicator.startAnimating()
        
        self.unstableUser = []
        for i in 0 ..< users.count {
            self.unstableUser.append(users[i])
            self.unstableUser.sortInPlace { $0.userName < $1.userName }
        }
        // Added first user again, to allow top menu to work. Else 1st row wont show
        //unstableUser.insert(users[0], atIndex: 0)
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.myActivityIndicator.stopAnimating()

            self.myTableView.reloadData()
        }
        
    }
    
    func populateStableUSers(users:[SummaryPatient]) {
        
        self.stableUser = []
        myActivityIndicator.startAnimating()
        
        for i in 0 ..< users.count {
            
            self.stableUser.append(users[i])
            self.stableUser.sortInPlace { $0.userName < $1.userName }
        }
        // Added first user again, to allow top menu to work. Else 1st row wont show
        //stableUser.insert(users[0], atIndex: 0)
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.myActivityIndicator.stopAnimating()
            self.myTableView.reloadData()
        }
        
    }
    
    func populateFetchedUsers(users:[User]) {
        //print("- Users counting", users.count)
        myActivityIndicator.startAnimating()
        self.fetchedUser = []
        for i in 0 ..< users.count {
            self.fetchedUser.append(users[i])
            self.fetchedUser.sortInPlace { $0.userName < $1.userName }
        }
        // Added first user again, to allow top menu to work. Else 1st row wont show
        //fetchedUser.insert(users[0], atIndex: 0)
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.myActivityIndicator.stopAnimating()

            self.myTableView.reloadData()

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = myTableView.indexPathForSelectedRow {
                
                
                //                let object = fetchedUser[indexPath.row]
                switch (mySegmentedController.selectedSegmentIndex) {
                case 0:
                    let object = unstableUser[indexPath.row]
                    let controller0 = segue.destinationViewController as! UITabBarController
                    
                    let controller2 = controller0.viewControllers?.first as! UINavigationController
                    
                    let controller = controller2.topViewController as! SymptomsViewController
                    
                    controller.detailPatient = object
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    //controller.navigationItem.leftItemsSupplementBackButton = true
                    break
                case 1:
                    let object = stableUser[indexPath.row]
                    let controller0 = segue.destinationViewController as! UITabBarController
                    
                    let controller2 = controller0.viewControllers?.first as! UINavigationController
                    
                    let controller = controller2.topViewController as! SymptomsViewController
                    
                    controller.detailPatient = object
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    //controller.navigationItem.leftItemsSupplementBackButton = true
                    
                    break
                case 2:
                    let object = fetchedUser[indexPath.row]
                    let controller0 = segue.destinationViewController as! UITabBarController
                    
                    let controller2 = controller0.viewControllers?.first as! UINavigationController
                    
                    let controller = controller2.topViewController as! SymptomsViewController
                    
                    controller.detailItem = object
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    //controller.navigationItem.leftItemsSupplementBackButton = true
                    
                    break
                default:
                    break
                }
                
                
                
            }
        }
    }
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        var returnValue = 0
        
        switch (mySegmentedController.selectedSegmentIndex) {
        case 0:
            returnValue = unstableUser.count
            break
        case 1:
            returnValue = stableUser.count
            break
        case 2:
            returnValue = fetchedUser.count
        default:
            break
        }
        
        return returnValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("patientsCell", forIndexPath: indexPath) as! PatientsTableViewCell
        
        cell.weightImage.image = UIImage(named: "weight")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
        
        cell.bpImage.image = UIImage(named: "symptoms")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
        
        cell.symptomsImage.image = UIImage(named: "blood-pressure")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
        
        switch (mySegmentedController.selectedSegmentIndex) {
        case 0:
            let object = unstableUser[indexPath.row]
            cell.patientNameLabel.text = object.userName
            if object.weight == 1 {
                cell.weightImage.image = UIImage(named: "weight")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0))
            } else { cell.weightImage.image = UIImage(named: "weight")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0)) }
            
            if object.symptom > 1 {
                cell.symptomsImage.image = UIImage(named: "symptoms")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0))
            } else { cell.bpImage.image = UIImage(named: "symptoms")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0)) }
            
            if object.bloodPressure == 1  {
                cell.bpImage.image = UIImage(named: "blood-pressure")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0))
            } else { cell.bpImage.image = UIImage(named: "blood-pressure")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0)) }
            
       
            
            print("- there is a weight: ", object.weight)
            print("- there is a bp: ", object.bloodPressure)
            print("- there is a symptom: ", object.symptom)

            print("unstable selected")
            break
            
        case 1:
            let object = stableUser[indexPath.row]
            cell.patientNameLabel.text = object.userName
            cell.weightImage.image = UIImage(named: "weight")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
            
            cell.bpImage.image = UIImage(named: "symptoms")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
            
            cell.symptomsImage.image = UIImage(named: "blood-pressure")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
            print("stable selected")
            
            break
            
            
        case 2:
            let object = fetchedUser[indexPath.row]
            cell.patientNameLabel.text = object.userName
            
            cell.weightImage.image = UIImage(named: "weight")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
            
            cell.bpImage.image = UIImage(named: "symptoms")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
            
            cell.symptomsImage.image = UIImage(named: "blood-pressure")!.tintWithColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0))
            print("all patients selected")
            
            break
        default:
            break
        }
        
        return cell
        
        
    }
    
    @IBAction func refreshPatients(sender: AnyObject) {
        dataService.fetchUsers(populateFetchedUsers)
        dataService.fetchUnstablePatient(populateUnstableUSers)
        dataService.fetchStablePatient(populateStableUSers)
    }
    
    @IBAction func mySegmentedControlButton(sender: AnyObject) {

        myTableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        
//        // UITableView only moves in one direction, y axis
//        let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//
//        
//        let currentOffset = scrollView.contentOffset.y
//        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//        
//        // Change 10.0 to adjust the distance from bottom
//        if maximumOffset - currentOffset <= 10.0 {
//            print("has reached the bootom")
//            
//            pagingSpinner.startAnimating()
//            
//            myTableView.reloadData()
//            
//        }
//        pagingSpinner.color = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
//        pagingSpinner.hidesWhenStopped = true
//        myTableView.tableHeaderView = pagingSpinner
//        pagingSpinner.stopAnimating()
//    
//    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseDetailViewController = false
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            fetchedUser.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}
