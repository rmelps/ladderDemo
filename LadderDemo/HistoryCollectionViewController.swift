//
//  HistoryCollectionViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/4/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HistoryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let reuseIdentifier = "HistoryCell"
    let sectionInsets = UIEdgeInsets(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0)
    let itemsPerRow: CGFloat = 1
    var specificTabBarController: UITabBarController!
    var latch = true

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let tabVC = tabBarController as? CoachTabBarViewController {
            
            if tabVC.selectedUser != nil {
                navigationItem.title = "History of \(tabVC.selectedUser!.firstName) \(tabVC.selectedUser!.lastName)"
            } else {
                navigationItem.title = "Select a User first!"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView?.reloadData()
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
        
        if let tabVC = tabBarController as? CoachTabBarViewController {
            let weeks = tabVC.weeks
            print(weeks)
            count = weeks.count
        }
        
        if let tabVC = tabBarController as? UserTabBarViewController {
            let weeks = tabVC.weeks
            print(weeks)
            count = weeks.count
        }
        
        return count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HistoryCollectionViewCell
        print("creating cell")
        
        if let tabVC = tabBarController as? CoachTabBarViewController {
            
            if let selectedUser = tabVC.selectedUser {
                cell.contentView.isHidden = false
                let week = tabVC.weeks[indexPath.row]
                cell.titleLabel.text = "Week of \(week)"
                
                tabVC.promiseDBRef.child(tabVC.databaseWeeks[indexPath.row]).child(selectedUser.uid).observeSingleEvent(of: .value, with: { (snapShot:FIRDataSnapshot) in
                    if snapShot.value is NSNull {
                        cell.promiseLabe.text = "User Was Not Assigned a Promise This Week"
                        cell.statusImageView.isHidden = true
                        cell.statusLabel.isHidden = true
                        return
                    }
                    
                    let snapVal = snapShot.value as! [String: String]
                    let keys = snapVal.keys
                    
                    DispatchQueue.main.async {
                        for key in keys {
                            let val = snapVal[key]
                            if val == "1" {
                                cell.statusImageView.image = UIImage(named: "failed")
                                cell.statusLabel.text = "Failed!"
                                cell.statusLabel.textColor = .red
                                break
                            }
                            if val == "0" {
                                cell.statusImageView.image = UIImage(named: "incomplete")
                                cell.statusLabel.text = "Incomplete!"
                                cell.statusLabel.textColor = .darkGray
                                break
                            }
                            if val == "2" {
                                cell.statusImageView.image = UIImage(named: "complete")
                                cell.statusLabel.text = "Complete!"
                                cell.statusLabel.textColor = .green
                            }
                        }
                        cell.statusImageView.isHidden = false
                        cell.statusLabel.isHidden = false
                        cell.promiseLabe.text = snapVal["content"]
                        
                        if self.latch {
                            collectionView.reloadData()
                            self.latch = false
                        }
                    }
                    
                })
            } else {
                cell.contentView.isHidden = true
            }
        }
        
        if let tabVC = tabBarController as? UserTabBarViewController {
            cell.titleLabel.text = "Week of \(tabVC.weeks[indexPath.row])"
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    
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

    

}
