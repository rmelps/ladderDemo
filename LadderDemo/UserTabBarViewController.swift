//
//  UserTabBarViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    // Passed on properties after sign in
    var signedInUser: User!
    var selectedCoach: Coach?
    var userDBRef: FIRDatabaseReference!
    var coachDBRef: FIRDatabaseReference!
    var promiseDBRef: FIRDatabaseReference!
    var profiles: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
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
    
    func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        return calendar.weekdaySymbols
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarOptions: NSCalendar.Options {
            switch self {
            case .Next:
                return .matchNextTime
            case .Previous:
                return [.searchBackwards, .matchNextTime]
            }
        }
    }
    
    func get(direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false) -> NSDate {
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
        
        let today = NSDate()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        if consider && calendar.component(.weekday, from: today as Date) == nextWeekDayIndex {
            return today
        }
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = calendar.nextDate(after: today as Date, matching: nextDateComponent as DateComponents, options: direction.calendarOptions)
        
        return date! as NSDate
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let fromView: UIView = tabBarController.selectedViewController!.view
        let toView: UIView = viewController.view
        if fromView == toView {
            return false
        }
        
        let indexFrom = tabBarController.viewControllers!.index(of: tabBarController.selectedViewController!)
        let indexTo = tabBarController.viewControllers!.index(of: viewController)
        
        if indexFrom! > indexTo! {
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: .transitionFlipFromLeft) { (complete) in
                toView.setNeedsLayout()
            }
        } else {
                UIView.transition(from: fromView, to: toView, duration: 0.3, options: .transitionFlipFromRight) { (complete) in
                    toView.setNeedsLayout()
            }
        }
        
        return true
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
