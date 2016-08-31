//
//  ACETableViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 25/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

protocol ACETableViewControllerDelegate: class {
    func acePicker(picker: ACETableViewController, didPickName aceName: String)
}

import UIKit

class ACETableViewController: UITableViewController {
    weak var delegate: ACETableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Angiotensin-converting Enzyme "
        
    


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

    let aceInhibitors = [ "Captopril", "Enalapril", "Lisinoprilb", "Ramipril" ]
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aceInhibitors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AceCell", forIndexPath: indexPath)
        
        let aceNames = aceInhibitors[indexPath.row]
        cell.textLabel!.text = aceNames
        //cell.imageView!.image = UIImage(named: iconName)
        
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            let aceName = aceInhibitors[indexPath.row]
            delegate.acePicker(self, didPickName: aceName)
        }
    }
}
