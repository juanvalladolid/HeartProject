//
//  DiureticTableViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 25/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//



protocol DiureticTableViewControllerDelegate: class {
    func diureticPicker(picker: DiureticTableViewController, didPickName diureticName: String)
}

import UIKit

class DiureticTableViewController: UITableViewController {
    weak var delegate: DiureticTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Diuretic"

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
    
    let typeDiuretics = ["Loop diuretics", "Thiazides"]
    
    let diuretics = [[ "Furosemide", "Bumetanide", "Torasemide"],["Bendroflumethiazide","Hydrochlorothiazide","Metolazone", "lndapamidec"]]
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diuretics[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiureticCell", forIndexPath: indexPath)
        
        let diureticNames = diuretics[indexPath.section][indexPath.row]
        cell.textLabel!.text = diureticNames
        //cell.imageView!.image = UIImage(named: iconName)
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            let diureticName = diuretics[indexPath.section][indexPath.row]
            delegate.diureticPicker(self, didPickName: diureticName)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return typeDiuretics.count
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < typeDiuretics.count {
            return typeDiuretics[section]
        }
        return nil
    }
    
}
