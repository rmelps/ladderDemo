//
//  CoachInViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 5/31/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

class CoachInViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    var coachTabBarController: CoachTabBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachTabBarController = tabBarController as! CoachTabBarViewController
        
        welcomeLabel.text = "Welcome \(coachTabBarController.signedInCoach.firstName)"
    }
    
}
