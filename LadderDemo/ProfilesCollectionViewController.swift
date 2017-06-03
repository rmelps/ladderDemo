//
//  ProfilesCollectionViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

private let reuseIdentifier = "Cell"

class ProfilesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
   
    let reuseIdentifier = "ProfileCell"
    let sectionInsets = UIEdgeInsets(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0)
    let itemsPerRow: CGFloat = 2
    var specificTabBarController: UITabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.allowsMultipleSelection = false
        
        if let tabVC = tabBarController as? CoachTabBarViewController {
            specificTabBarController = tabVC
            self.navigationController?.title = "My Users"
        } else {
            specificTabBarController = tabBarController as? UserTabBarViewController
            self.navigationController?.title = "Coaches"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        
        if let tabVC = specificTabBarController as? CoachTabBarViewController {
            if let children = tabVC.signedInCoach.children?.count {
                count = children
            }
        }
        if let tabVC = specificTabBarController as? UserTabBarViewController {
            if let children = tabVC.profiles?.count {
                count = children
            }
        }
        return count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileCollectionViewCell
        cell.backgroundColor = .blue
        cell.activityIndicator.startAnimating()
        print("creating cell...")
        
        let index = indexPath.row
        if let coachTabBarController = specificTabBarController as? CoachTabBarViewController {
        
            if let userForCell = coachTabBarController.signedInCoach.children?[index] {
                coachTabBarController.userDBRef.child(userForCell).observe(.value, with: { (snapShot:   FIRDataSnapshot) in
                    let user = User(uid: userForCell, snapShot: snapShot)
                    cell.nameLabel.text = user.firstName
                    cell.uid = user
                    print("found children...")
                
                    if user.photoPath != "nil" {
                        print("found photo")
                    } else {
                        cell.profileImageView.image = UIImage(named: "default-avatar")
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.isHidden = true
                        }
                    })
            }
        }
        if let userTabBarController = specificTabBarController as? UserTabBarViewController {
            if let coachForCell = userTabBarController.profiles?[index] {
                userTabBarController.coachDBRef.child(coachForCell).observe(.value, with: { (snapShot:FIRDataSnapshot) in
                    let coach = Coach(uid: coachForCell, snapShot: snapShot)
                    cell.nameLabel.text = coach.firstName
                    cell.uid = coach
                    
                    if coach.photoPath != "nil" {
                        print("found photo")
                    } else {
                        cell.profileImageView.image = UIImage(named: "default-avatar")
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.isHidden = true
                    }
                })
            }
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCollectionViewCell
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = UIColor.green.cgColor
        
        if let tabVC = specificTabBarController as? CoachTabBarViewController {
            tabVC.selectedUser = cell.uid
        }
        if let tabVC = specificTabBarController as? UserTabBarViewController {
            tabVC.selectedCoach = cell.uid as? Coach
            
            if let children = tabVC.selectedCoach?.children, children.contains(tabVC.signedInUser.uid) {
            } else {
                if let coach = tabVC.selectedCoach {
                    coach.children?.append(tabVC.signedInUser.uid)
                    tabVC.coachDBRef.child(coach.uid).child("children").setValue(coach.children as Any)
                }
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCollectionViewCell
        cell.layer.borderWidth = 0.0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        if let tabVC = specificTabBarController as? UserTabBarViewController {
            if let coach = tabVC.selectedCoach {
                if coach.children!.contains(tabVC.signedInUser.uid) {
                    let index = coach.children?.index(of: tabVC.signedInUser.uid)
                    coach.children?.remove(at: index!)
                    tabVC.coachDBRef.child(coach.uid).child("children").setValue(coach.children as Any)
                }
            }
        }
    }
}
