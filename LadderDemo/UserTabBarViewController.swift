//
//  UserTabBarViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserTabBarViewController: UITabBarController {
    
    // Passed on properties after sign in
    var signedInUser: User!
    var userDBRef: FIRDatabaseReference!
    var coachDBRef: FIRDatabaseReference!
    var promiseDBRef: FIRDatabaseReference!
    var profiles: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        promiseDBRef = FIRDatabase.database().reference().child("promises")
        
        coachDBRef.observe(.value, with: { (snapShot:FIRDataSnapshot) in
            print("observed event")
            var keys = [String]()
            for child in snapShot.children.allObjects {
                let snap = child as! FIRDataSnapshot
                let key = snap.key
                keys.append(key)
            }
            print(keys)
            self.profiles = keys
            print(self.profiles ?? "no profiles found")
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
