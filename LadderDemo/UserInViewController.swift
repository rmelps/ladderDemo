//
//  UserInViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserInViewController: UIViewController {
    @IBOutlet weak var homeScreenImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    var userTabViewController: UserTabBarViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTabViewController = tabBarController as! UserTabBarViewController
        
        userNameLabel.text = "\(userTabViewController.signedInUser.firstName)"
        
        applyMotionEffect(toView: homeScreenImageView, magnitude: 40)
        applyMotionEffect(toView: userNameLabel, magnitude: -15)
        applyMotionEffect(toView: welcomeLabel, magnitude: -15)
        applyMotionEffect(toView: changePhotoButton, magnitude: -15)
        applyMotionEffect(toView: logOutButton, magnitude: -15)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.setNeedsLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "userLogOutSegue":
            let vc = segue.destination as! MainMenuViewController
            for field in vc.textFields {
                field.text = ""
            }
        default:
            break
        }
    }
    
    @IBAction func changePhotoButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        self.performSegue(withIdentifier: "userLogOutSegue", sender: self)
    }
    
    func applyMotionEffect(toView view:UIView, magnitude: Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        view.addMotionEffect(xMotion)
    }
    

}
