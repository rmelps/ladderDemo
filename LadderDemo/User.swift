//
//  User.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 5/31/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct User {
    let uid: String
    var email: String
    var firstName: String
    var lastName: String
    let itemRef: FIRDatabaseReference?
    
    init(userData: FIRUser, snapShot: FIRDataSnapshot) {
        uid = userData.uid
        
        itemRef = snapShot.ref
        
        let snapShotValue = snapShot.value as? [String: AnyObject]
        
        if let mail = userData.providerData.first?.email {
            email = mail
        } else {
            email = ""
        }
        if let firstName = snapShotValue?["firstName"] as? String {
            self.firstName = firstName
        } else {
            firstName = "no first name"
        }
        if let lastName = snapShotValue?["lastName"] as? String {
            self.lastName = lastName
        } else {
            lastName = "no last name"
        }
    }
    
    init(uid:String, email:String, firstName: String, lastName: String) {
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.itemRef = nil
    }
    
    func toAny() -> Any {
        return ["uid":uid, "email":email, "firstName":firstName, "lastName": lastName]
    }
}