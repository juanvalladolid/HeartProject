//
//  BetaBlockerTableViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 25/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

protocol BetaBlockerTableViewControllerDelegate: class {
    func betaBlockerPicker(picker: BetaBlockerTableViewController, didPickName betaBlockerName: String)
}

import UIKit

class BetaBlockerTableViewController: UITableViewController {
    weak var delegate: BetaBlockerTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Beta Blockers"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    let betaBlockers = [ "Bisoprolol", "Carvedilol", "Metoprolol succinate (CR/XL)", "Nebivololc" ]
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return betaBlockers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BetaBlockerCell", forIndexPath: indexPath)
        
        let betaBlockerNames = betaBlockers[indexPath.row]
        cell.textLabel!.text = betaBlockerNames
        //cell.imageView!.image = UIImage(named: iconName)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            let betaBlockerName = betaBlockers[indexPath.row]
            delegate.betaBlockerPicker(self, didPickName: betaBlockerName)
        }
    }


}
