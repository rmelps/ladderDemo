//
//  Promise.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/2/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Promise: NSObject {
    
    var content: String
    var monday: String
    var tuesday: String
    var wednesday: String
    var thursday: String
    var friday: String
    var saturday: String
    var sunday: String
    
    init(content: String) {
        self.content = content
        self.monday = "0"
        self.tuesday = "0"
        self.wednesday = "0"
        self.thursday = "0"
        self.friday = "0"
        self.saturday = "0"
        self.sunday = "0"
    }
    
    init(snapShot: FIRDataSnapshot) {
        
        let snapShotValue = snapShot.value as? [String: AnyObject]
        
        if let content = snapShotValue?["content"] as? String {
            self.content = content
        } else {
            content = ""
        }
        if let monday = snapShotValue?["monday"] as? String {
            self.monday = monday
        } else {
            monday = ""
        }
        if let tuesday = snapShotValue?["tuesday"] as? String {
            self.tuesday = tuesday
        } else {
            tuesday = ""
        }
        if let wednesday = snapShotValue?["wednesday"] as? String {
            self.wednesday = wednesday
        } else {
            wednesday = ""
        }
        if let thursday = snapShotValue?["thursday"] as? String {
            self.thursday = thursday
        } else {
            thursday = ""
        }
        if let friday = snapShotValue?["friday"] as? String {
            self.friday = friday
        } else {
            friday = ""
        }
        if let saturday = snapShotValue?["saturday"] as? String {
            self.saturday = saturday
        } else {
            saturday = ""
        }
        if let sunday = snapShotValue?["sunday"] as? String {
            self.sunday = sunday
        } else {
            sunday = ""
        }
    }
    
    func toAny() -> Any {
        return ["content":content, "monday":monday, "tuesday":tuesday, "wednesday": wednesday, "thursday": thursday, "friday": friday, "saturday": saturday, "sunday": sunday]
    }
    
}
