//
//  PromiseCell.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/2/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

class PromiseCell: UITableViewCell {
    
    @IBOutlet weak var promiseLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        promiseLabel.adjustsFontForContentSizeCategory = true
        
    }
}
