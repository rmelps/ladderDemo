//
//  Coach.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class Coach: User {
    var children: [String]?
    
    override init(uid: String, email: String, firstName: String, lastName: String) {
        children = nil
        super.init(uid: uid, email: email, firstName: firstName, lastName: lastName)
    }
    
    override init(userData: FIRUser, snapShot: FIRDataSnapshot) {
        
        let snapShotValue = snapShot.value as? [String: AnyObject]
        
        if let children = snapShotValue?["children"] as? [String] {
            self.children = children
        } else {
            children = nil
        }
        
        super.init(userData: userData, snapShot: snapShot)
    }
    
    override func toAny() -> Any {
        return ["uid":uid, "email":email, "firstName":firstName, "lastName": lastName, "children": children ?? [String]()]
    }
}
