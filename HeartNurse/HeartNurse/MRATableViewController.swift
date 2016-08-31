//
//  MRATableViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 25/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

protocol MRATableViewControllerDelegate: class {
    func mraPicker(picker: MRATableViewController, didPickName mraName: String)
}

import UIKit

class MRATableViewController: UITableViewController {
    weak var delegate: MRATableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Mineralocorticoid Receptor Antagonist"
        
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
    
    let mra = ["Eplerenone", "Spironolactone"]
    //let mra = ["xxxx", "yyyy"]
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mra.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MRACell", forIndexPath: indexPath)
        
        let mraNames = mra[indexPath.row]
        cell.textLabel!.text = mraNames
        //cell.imageView!.image = UIImage(named: iconName)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            let mraName = mra[indexPath.row]
            delegate.mraPicker(self, didPickName: mraName)
            
        }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .Checkmark
            
        }
    }
}