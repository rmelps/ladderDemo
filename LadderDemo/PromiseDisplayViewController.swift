//
//  PromiseDisplayViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/2/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PromiseDisplayViewController: UIViewController {
    @IBOutlet weak var promiseContentLabel: UILabel!
    @IBOutlet weak var sundayIndicator: UIImageView!
    @IBOutlet weak var mondayIndicator: UIImageView!
    @IBOutlet weak var tuesdayIndicator: UIImageView!
    @IBOutlet weak var wednesdayIndicator: UIImageView!
    @IBOutlet weak var thursdayIndicator: UIImageView!
    @IBOutlet weak var fridayIndicator: UIImageView!
    @IBOutlet weak var saturdayIndicator: UIImageView!
    
    @IBOutlet weak var completeButton: RoundButton!
    
    var indicators = [UIImageView]()
    var promise: Promise?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        promiseContentLabel.layer.cornerRadius = 3.0
        promiseContentLabel.layer.borderWidth = 4.0
        promiseContentLabel.layer.borderColor = UIColor.white.cgColor
        
        indicators.append(sundayIndicator)
        indicators.append(mondayIndicator)
        indicators.append(tuesdayIndicator)
        indicators.append(wednesdayIndicator)
        indicators.append(thursdayIndicator)
        indicators.append(fridayIndicator)
        indicators.append(saturdayIndicator)
        
        completeButton.addTarget(self, action: #selector(PromiseDisplayViewController.onTapDown(_:)), for: .touchDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if let tabVC = tabBarController as? CoachTabBarViewController {
            if let user = tabVC.selectedUser {
                let uid = user.uid
                completeButton.isHidden = false
                completeButton.setBackgroundImage(tabVC.selectedImage, for: .normal)
                completeButton.layer.cornerRadius = 4.0
                completeButton.clipsToBounds = true
                completeButton.isEnabled = false
                completeButton.setTitle("", for: .normal)
                
                let date = tabVC.get(direction: .Previous, "Sunday", considerToday: true)
                
                let dateRef = tabVC.promiseDBRef.child("\(date)")
                
                dateRef.observe(.value, with: { (snapShot:FIRDataSnapshot) in
                    if snapShot.hasChild(uid) {
                        self.completeButton.isEnabled = true
                        let uidSnap = snapShot.childSnapshot(forPath: uid)
                        self.promise = Promise(snapShot: uidSnap)
                        self.promiseContentLabel.text = self.promise?.content
                        
                        let snapValue = uidSnap.value as! [String: String]
                        
                        for indicator in self.indicators {
                            if let id = indicator.accessibilityIdentifier {
                                
                                if snapValue[id] == "0" {
                                    indicator.image = UIImage(named: "incomplete")
                                }
                                if snapValue[id] == "1" {
                                    indicator.image = UIImage(named: "failed")
                                }
                                if snapValue[id] == "2" {
                                    indicator.image = UIImage(named: "complete")
                                }
                               
                            }
                        }
                    } else {
                        self.completeButton.isEnabled = true
                        self.promiseContentLabel.text = "You Haven't Assigned a Promise Yet!"
                    }
                })
            } else {
                self.completeButton.isHidden = true
                self.completeButton.isEnabled = false
                self.promiseContentLabel.text = "Choose a User first!"
            }
        }
        
        if let tabVC = tabBarController as? UserTabBarViewController {
            if let user = tabVC.signedInUser {
                
                let uid = user.uid
                
                let date = tabVC.get(direction: .Previous, "Sunday", considerToday: true)
                
                
                let dateRef = tabVC.promiseDBRef.child("\(date)")
                
                dateRef.observe(.value, with: { (snapShot:FIRDataSnapshot) in
                    if snapShot.hasChild(uid) {
                        self.completeButton.isEnabled = true
                        let uidSnap = snapShot.childSnapshot(forPath: uid)
                        self.promise = Promise(snapShot: uidSnap)
                        self.promiseContentLabel.text = self.promise?.content
                        
                        let snapValue = uidSnap.value as! [String: String]
                        
                        for indicator in self.indicators {
                            if let id = indicator.accessibilityIdentifier {
                                
                                if snapValue[id] == "0" {
                                    indicator.image = UIImage(named: "incomplete")
                                }
                                if snapValue[id] == "1" {
                                    indicator.image = UIImage(named: "failed")
                                }
                                if snapValue[id] == "2" {
                                    indicator.image = UIImage(named: "complete")
                                }
                                
                            }
                        }
                    } else {
                        self.completeButton.isEnabled = false
                        self.promiseContentLabel.text = "Your Coach Hasn't Set a Promise Yet!"
                    }
                })
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func completePromise(_ sender: RoundButton) {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let localDate = dateFormatter.string(from: date)
        let dayOfWeek = localDate.lowercased()
        
        for (index, indicator) in indicators.enumerated() {
            if let id = indicator.accessibilityIdentifier {
                if id == dayOfWeek {
                    if let tabVC = tabBarController as? UserTabBarViewController {
                        let date = tabVC.get(direction: .Previous, "Sunday", considerToday: true)
                        let ref = tabVC.promiseDBRef.child("\(date)").child(tabVC.signedInUser.uid)
                        
                        let complete = "2"
                        
                        switch index {
                        case 0:
                            promise?.sunday = complete
                        case 1:
                            promise?.monday = complete
                        case 2:
                            promise?.tuesday = complete
                        case 3:
                            promise?.wednesday = complete
                        case 4:
                            promise?.thursday = complete
                        case 5:
                            promise?.friday = complete
                        case 6:
                            promise?.saturday = complete
                        default:
                            break
                        }
                        
                        ref.setValue(self.promise?.toAny(), withCompletionBlock: { (error:Error?, ref:FIRDatabaseReference) in
                            if error == nil {
                                indicator.image = UIImage(named: "complete")
                            }
                        })
                    }
                }
            }
        }
        
    }
    
    func onTapDown(_ sender: UIButton) {
        
        let radius = sender.frame.width / 2
        let position = sender.center
        let pulse = Pulsing(numberOfPulses: 1, radius: radius * 4.5, position: position)
        pulse.animationDuration = 0.8
        
        if tabBarController is CoachTabBarViewController {
            pulse.backgroundColor = UIColor.red.cgColor
        }
        if tabBarController is UserTabBarViewController {
            pulse.backgroundColor = UIColor.green.cgColor
        }
    
        self.view.layer.insertSublayer(pulse, below: sender.layer)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
