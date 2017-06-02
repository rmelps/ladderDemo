//
//  UserInViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

class UserInViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    var userTabViewController: UserTabBarViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTabViewController = tabBarController as! UserTabBarViewController
        
        welcomeLabel.text = "Welcome \(userTabViewController.signedInUser.firstName)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
