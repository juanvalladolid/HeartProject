//
//  ResearchContainerViewController.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/05/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import ResearchKit

class ResearchContainerViewController: UIViewController {
    // MARK: HealthClientType
    
//    var healthStore: HKHealthStore?
    
    // MARK: Propertues
    
    var contentHidden = false {
        didSet {
            guard contentHidden != oldValue && isViewLoaded() else { return }
            childViewControllers.first?.view.hidden = contentHidden
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            toStudy()
        }
        else {
            toOnboarding()
        }
        
        
        super.viewDidLoad()

    }

    

    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        super.prepareForSegue(segue, sender: sender)
//        
//        if let healthStore = healthStore {
//            segue.destinationViewController.injectHealthStore(healthStore)
//        }
//    }
    
    // MARK: Unwind segues
    
    @IBAction func unwindToStudy(segue: UIStoryboardSegue) {
        toStudy()
    }
    
    @IBAction func unwindToWithdrawl(segue: UIStoryboardSegue) {
        toWithdrawl()
    }
    
    // MARK: Transitions
    
    func toOnboarding() {
        performSegueWithIdentifier("toOnboarding", sender: self)
    }
    
    func toStudy() {
        performSegueWithIdentifier("toStudy", sender: self)
    }
    
    func toWithdrawl() {
        let viewController = WithdrawViewController()
        viewController.delegate = self
        
        presentViewController(viewController, animated: true, completion: nil)
    }
}


extension ResearchContainerViewController: ORKTaskViewControllerDelegate {
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        // Check if the user has finished the `WithdrawViewController`.
        if taskViewController is WithdrawViewController {
            /*
             If the user has completed the withdrawl steps, remove them from
             the study and transition to the onboarding view.
             */
            if reason == .Completed {
                //ORKPasscodeViewController.removePasscodeFromKeychain()
                toOnboarding()
            }
            
            // Dismiss the `WithdrawViewController`.
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
