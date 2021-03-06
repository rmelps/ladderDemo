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
import FirebaseStorage

class ProfilesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
   
    let reuseIdentifier = "ProfileCell"
    let sectionInsets = UIEdgeInsets(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0)
    let itemsPerRow: CGFloat = 2
    var specificTabBarController: UITabBarController!
    
    // File storage references
    var storage: FIRStorage!
    var storageRef: FIRStorageReference!
    var imagesRef: FIRStorageReference!
    
    var selectedCellIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.allowsMultipleSelection = false
        
        if let tabVC = tabBarController as? CoachTabBarViewController {
            specificTabBarController = tabVC
            navigationItem.title = "My Trainees"
        } else {
            specificTabBarController = tabBarController as? UserTabBarViewController
            navigationItem.title = "Available Coaches"
        }
        
        storage = FIRStorage.storage()
        storageRef = storage.reference()
        imagesRef = storageRef.child("profileImages")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if selectedCellIndexPath != nil {
           // collectionView?.selectItem(at: self.selectedCellIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
        }
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
                    
                
                    if cell.uid?.photoPath != "nil" {
                        // Create a reference to the file that will be downloaded
                        let reference = self.storage.reference(forURL: cell.uid!.photoPath)
                        // Download image at path to local memory with defined maximum size
                        reference.data(withMaxSize: 10 * 1024 * 1024) { (data:Data?, error:Error?) in
                            
                            cell.activityIndicator.stopAnimating()
                            cell.activityIndicator.isHidden = true
                            
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            if let data = data {
                                cell.profileImageView.image = UIImage(data: data)!
                            }
                        }
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
                    
                    if coachForCell == userTabBarController.signedInUser.coach {
                        self.selectedCellIndexPath = indexPath
                        cell.selectedCell = true
                    } else {
                        cell.selectedCell = false
                    }
                    
                    if coach.photoPath != "nil" {
                        print("found photo")
                        // Create a reference to the file that will be downloaded
                        let reference = self.storage.reference(forURL: cell.uid!.photoPath)
                        // Download image at path to local memory with defined maximum size
                        reference.data(withMaxSize: 10 * 1024 * 1024) { (data:Data?, error:Error?) in
                            
                            cell.activityIndicator.stopAnimating()
                            cell.activityIndicator.isHidden = true
                            
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            if let data = data {
                                cell.profileImageView.image = UIImage(data: data)!
                            }
                        }

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
        
        if selectedCellIndexPath != nil {
            let thatCell = collectionView.cellForItem(at: selectedCellIndexPath!) as! ProfileCollectionViewCell
            configCell(cell: thatCell, selected: false)
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCollectionViewCell
        
        self.configCell(cell: cell, selected: true)
        self.selectedCellIndexPath = indexPath
        
        if let tabVC = specificTabBarController as? CoachTabBarViewController {
            tabVC.selectedUser = cell.uid
            tabVC.selectedImage = cell.profileImageView.image!
        }
        if let tabVC = specificTabBarController as? UserTabBarViewController {
            tabVC.selectedCoach = cell.uid as? Coach
            
            if let children = tabVC.selectedCoach?.children, children.contains(tabVC.signedInUser.uid) {
            } else {
                if let coach = tabVC.selectedCoach {
                    tabVC.signedInUser.coach = coach.uid
                    tabVC.userDBRef.child(tabVC.signedInUser.uid).setValue(tabVC.signedInUser.toAny())
                    coach.children?.append(tabVC.signedInUser.uid)
                    tabVC.coachDBRef.child(coach.uid).child("children").setValue(coach.children as Any)
                }
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCollectionViewCell
        
        self.configCell(cell: cell, selected: false)
        
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
    func configCell(cell: ProfileCollectionViewCell, selected: Bool) {
        
        if selected {
            cell.selectedCell = true
        } else {
            cell.selectedCell = false
        }
    }
}
