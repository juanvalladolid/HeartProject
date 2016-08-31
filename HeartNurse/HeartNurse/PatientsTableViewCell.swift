//
//  PatientsTableViewCell.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 22/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit

class PatientsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBOutlet weak var patientNameLabel: UILabel!
    
    @IBOutlet weak var weightImage: UIImageView!
    @IBOutlet weak var bpImage: UIImageView!
    @IBOutlet weak var symptomsImage: UIImageView!
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
