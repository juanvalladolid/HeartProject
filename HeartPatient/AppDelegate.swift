//
//  AppDelegate.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/05/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import CoreData

import ResearchKit

import Firebase
import FirebaseAuth
import FirebaseDatabase

import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    var window: UIWindow?

    //    var containerViewController: ResearchContainerViewController? {
    //        return window?.rootViewController as? ResearchContainerViewController
    var containerViewController: ResearchContainerViewController? {
        return window?.rootViewController as? ResearchContainerViewController
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        if FIRAuth.auth()?.currentUser != nil  {

            print("- From app delegate user exists")
            
        }
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))

        
        //ORKPasscodeViewController.removePasscodeFromKeychain()
        
        FIRApp.configure()
        

        checkIfUserIsNotloggedIn()
        //lockApp()
        
        
        Fabric.with([Crashlytics.self])

        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            containerViewController?.contentHidden = true
        }
        
    }
    
    
    func applicationDidEnterBackground(application: UIApplication) {
        print("app is in background")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        lockApp()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        print("app did become active")
        lockApp()
        
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        // CORE DATA
        // self.saveContext()
    }
    
    
    func lockApp() {
        
        /*
         Only lock the app if there is a stored passcode and a passcode
         controller isn't already being shown.
         */
        guard ORKPasscodeViewController.isPasscodeStoredInKeychain() && !(containerViewController?.presentedViewController is ORKPasscodeViewController) else {
            
            return
        }
        
        window?.makeKeyAndVisible()
        
        let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewControllerWithText("Welcome back to HeartPatient App", delegate: self) as! ORKPasscodeViewController
        containerViewController?.presentViewController(passcodeViewController, animated: false, completion: nil)
    }
    
    func login() {
        if FIRAuth.auth()?.currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let naviVC = storyboard.instantiateViewControllerWithIdentifier("studyStoryBoard") as! UITabBarController
            window?.rootViewController = naviVC
        }
    }
    
    func checkIfUserIsNotloggedIn() {
        if FIRAuth.auth()?.currentUser?.displayName == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let naviVC = storyboard.instantiateViewControllerWithIdentifier("ResearchMain")
            window?.rootViewController = naviVC
        }
    }
    
    func logout() {
        do {
            let fireAuth = FIRAuth.auth()
            try fireAuth?.signOut()
            //self.navigationController?.popToRootViewControllerAnimated(true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let naviVC = storyboard.instantiateViewControllerWithIdentifier("ResearchMain")
            window?.rootViewController = naviVC
            print("- User has logged out and sent to ResearchMain")
            
        } catch let signOutError  {
            print ("- JUAN, THERE WAS AN ERROR signing out: %@", signOutError)
        }
    
    }

    
    
    // MARK: - Core Data stack
    
    //    lazy var applicationDocumentsDirectory: NSURL = {
    //        // The directory the application uses to store the Core Data store file. This code uses a directory named "Thesis.HeartPatient" in the application's documents Application Support directory.
    //        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    //        return urls[urls.count-1]
    //    }()
    //
    //    lazy var managedObjectModel: NSManagedObjectModel = {
    //        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    //        let modelURL = NSBundle.mainBundle().URLForResource("HeartPatient", withExtension: "momd")!
    //        return NSManagedObjectModel(contentsOfURL: modelURL)!
    //    }()
    //
    //    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    //        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    //        // Create the coordinator and store
    //        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    //        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
    //        var failureReason = "There was an error creating or loading the application's saved data."
    //        do {
    //            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    //        } catch {
    //            // Report any error we got.
    //            var dict = [String: AnyObject]()
    //            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
    //            dict[NSLocalizedFailureReasonErrorKey] = failureReason
    //
    //            dict[NSUnderlyingErrorKey] = error as NSError
    //            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
    //            // Replace this with code to handle the error appropriately.
    //            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
    //            abort()
    //        }
    //
    //        return coordinator
    //    }()
    //
    //    lazy var managedObjectContext: NSManagedObjectContext = {
    //        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    //        let coordinator = self.persistentStoreCoordinator
    //        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    //        managedObjectContext.persistentStoreCoordinator = coordinator
    //        return managedObjectContext
    //    }()
    //
    //    // MARK: - Core Data Saving support
    //
    //    func saveContext () {
    //        if managedObjectContext.hasChanges {
    //            do {
    //                try managedObjectContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nserror = error as NSError
    //                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
    //                abort()
    //            }
    //        }
    //    }
    
}

extension AppDelegate: ORKPasscodeDelegate {
    
    func passcodeViewControllerDidFinishWithSuccess(viewController: UIViewController) {
        containerViewController!.contentHidden = false
        viewController.dismissViewControllerAnimated(true, completion: nil)
        print("passcode was good")
    }
    
    func passcodeViewControllerDidFailAuthentication(viewController: UIViewController) {
        //containerViewController!.contentHidden = false
        //viewController.dismissViewControllerAnimated(true, completion: nil)
        print("failed passcode")
    }
    
}