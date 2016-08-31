//
//  OnboardingViewController.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/05/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import ResearchKit
import Firebase
import FirebaseAuth
//import FirebaseDatabase

class OnboardingViewController: UIViewController, UITextFieldDelegate {
    
    var dataService:FirebaseDataService = FirebaseDataService()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var newParameters = [AnyObject]()
    
    //var refOnBoarding:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.text = ""
        self.passwordField.text = ""
        
        
        //self.refOnBoarding = FIRDatabase.database().reference()
        
        // text field delegates
        emailField.delegate = self
        passwordField.delegate = self
        
        // set return key styles
        emailField.returnKeyType = UIReturnKeyType.Next
        passwordField.returnKeyType = UIReturnKeyType.Go

        
        // only enable 'go' key of textField2 if the field itself is non-empty
        passwordField.enablesReturnKeyAutomatically = true
        
        
        let tapper = UITapGestureRecognizer(target: view, action:#selector(UIView.endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }
    
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (emailField.text?.isEmpty ?? true) {
            passwordField.enabled = false
            textField.resignFirstResponder()
        }
        else if textField == emailField {
            passwordField.enabled = true
            passwordField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            let email = self.emailField.text!
            let password = self.passwordField.text!
            
            self.dataService.FirebaseLogIn(email, password: password)
            //self.performSegueWithIdentifier("unwindToStudy", sender: nil)

        }
        
        return true
    }
    
    
    // MARK: IB actions
    
    @IBAction func registerPatient(sender: UIButton) {
        
        // Main Consent to the app
        
        // Passcode creation
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode")
        passcodeStep.text = "Create a passcode to identify yourself to the app and protect access to information you've entered."
        
        let registrationStep = ORKRegistrationStep(identifier: "Registration", title: "Patient Registration", text: "Please fill up the fields", passcodeValidationRegex: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{4,15}$", passcodeInvalidMessage: "A valid password must be 4 and 15 characters long and include at least one numeric character.", options: [.IncludeGivenName, .IncludeFamilyName])
        
        let healthDataStep = HealthDataStep(identifier: "Health")

        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "Welcome aboard Heart Patient."
        completionStep.text = "Your registration is completed"
        
//        let orderedTask = ORKOrderedTask(identifier: "Join", steps: [registrationStep, passcodeStep, completionStep])
        let orderedTask = ORKOrderedTask(identifier: "Join", steps: [registrationStep, healthDataStep, passcodeStep, completionStep])

        
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRunUUID: nil)
        taskViewController.delegate = self
        
        presentViewController(taskViewController, animated: true, completion: nil)
    }
}


extension OnboardingViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
        switch reason {
        case .Completed:
            print("task was completed")
            //performSegueWithIdentifier("unwindToStudy", sender: nil)
            
        case .Discarded, .Failed, .Saved:
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        if reason != .Discarded && reason != .Failed && reason != .Saved {
            
            let results = taskViewController.result.results as? [ORKStepResult]
            
            for stepResult: ORKStepResult in results! {
                    
                for result in stepResult.results! as [ORKResult] {
                    
                    if let questionResult = result as? ORKQuestionResult {
                        //print(questionResult.answer!)
                        self.newParameters.append(questionResult.answer!)
                    }
                }
            }
            
            let email = String(self.newParameters[0])
            let password = String(self.newParameters[1])
            let username = String(self.newParameters[4]) + " " + String(self.newParameters[3])
            let name = String(self.newParameters[3])
            let lastname = String(self.newParameters[4])
            print("- New data to register: ", email, password, username)
            self.dataService.FirebaseSignUp(name, lastname:lastname, username:username, email: email, password: password)
            
//            if FIRAuth.auth()?.currentUser != nil {
//                self.performSegueWithIdentifier("unwindToStudy", sender: nil)
//                print("- User not nil, going to study now")
//            }
            //self.performSegueWithIdentifier("unwindToStudy", sender: nil)
            
        }

    }
    
    @IBAction func loginPressedButton(sender: AnyObject) {
        let email = self.emailField.text!
        let password = self.passwordField.text!
        sender.resignFirstResponder()
        
        self.dataService.FirebaseLogIn(email, password: password)
        //print("- Logged with new method from button")
        //self.performSegueWithIdentifier("unwindToStudy", sender: nil)
    }
    
    
    
    func taskViewController(taskViewController: ORKTaskViewController, viewControllerForStep step: ORKStep) -> ORKStepViewController? {
        if step is HealthDataStep {
            let healthStepViewController = HealthDataStepViewController(step: step)
            return healthStepViewController
        }
        
        return nil
    }
}
