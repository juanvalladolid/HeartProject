//
//  ARBTableViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 25/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//


protocol ARBTableViewControllerDelegate: class {
    func arbPicker(picker: ARBTableViewController, didPickName arbName: String)
}

import UIKit

class ARBTableViewController: UITableViewController {
    weak var delegate: ARBTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Angiotensin Receptor Blocker"
        
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
    
    let arb = ["Candesartan", "Valsartan", "Losartanb"]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arb.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ARBCell", forIndexPath: indexPath)
        
        let arbNames = arb[indexPath.row]
        cell.textLabel!.text = arbNames
        //cell.imageView!.image = UIImage(named: iconName)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            let arbName = arb[indexPath.row]
            delegate.arbPicker(self, didPickName: arbName)
        }
    }
}
