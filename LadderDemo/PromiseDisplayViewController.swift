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
                
                let date = tabVC.get(direction: .Previous, "Sunday", considerToday: true)
                
                let dateRef = tabVC.promiseDBRef.child("\(date)")
                
                dateRef.observe(.value, with: { (snapShot:FIRDataSnapshot) in
                    if snapShot.hasChild(uid) {
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
        print("detected touch")
    }
    
    func onTapDown(_ sender: UIButton) {
        
        let radius = sender.frame.width / 2
        let position = sender.center
        let pulse = Pulsing(numberOfPulses: 1, radius: radius * 4.5, position: position)
        pulse.animationDuration = 0.8
        pulse.backgroundColor = UIColor.green.cgColor
        
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
