//
//  ProfileCollectionViewCell.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    var uid: User?
    
}
