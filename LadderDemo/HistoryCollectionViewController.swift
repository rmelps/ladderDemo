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
        
        if tabBarController is UserTabBarViewController {
            navigationItem.title = "My History"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let tabVC = tabBarController as? CoachTabBarViewController {
            
            if tabVC.selectedUser != nil {
                navigationItem.title = "History of \(tabVC.selectedUser!.firstName) \(tabVC.selectedUser!.lastName)"
                collectionView?.backgroundColor = UIColor(displayP3Red: 79/255, green: 199/255, blue: 113/255, alpha: 1.0)
            } else {
                navigationItem.title = "Select a User first!"
                collectionView?.backgroundColor = UIColor(displayP3Red: 96/255, green: 170/255, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView?.reloadData()
        
        if let tabVC = tabBarController as? CoachTabBarViewController {
            
            if tabVC.selectedUser == nil {
                let ac = UIAlertController(title: "No User Selected!", message: "Select a User in the User Tab to view the History Tab", preferredStyle: .alert)
                
                let confirm = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                    self.tabBarController?.selectedIndex = 3
                })
                
                ac.addAction(confirm)
                
                self.present(ac, animated: true, completion: nil)
            }
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
                        cell.progressView.progress = 0.0
                        return
                    }
                    
                    let snapVal = snapShot.value as! [String: String]
                    let keys = snapVal.keys
                    
                    DispatchQueue.main.async {
                        var completion: Float = 0
                        
                        for key in keys {
                            let val = snapVal[key]
                            if val == "2" {
                                completion += 1
                            }
                        }
                        
                        if completion < 7 {
                            cell.statusImageView.image = UIImage(named: "incomplete")
                            cell.statusLabel.text = "Incomplete!"
                            cell.statusLabel.textColor = .darkGray
                        } else {
                            cell.statusImageView.image = UIImage(named: "complete")
                            cell.statusLabel.text = "Complete!"
                            cell.statusLabel.textColor = .green
                        }
                        
                        cell.progressView.progress = completion / 7.0
                        
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
            cell.contentView.isHidden = false
            let week = tabVC.weeks[indexPath.row]
            cell.titleLabel.text = "Week of \(week)"
            
            tabVC.promiseDBRef.child(tabVC.databaseWeeks[indexPath.row]).child(tabVC.signedInUser.uid).observeSingleEvent(of: .value, with: { (snapShot:FIRDataSnapshot) in
                if snapShot.value is NSNull {
                    cell.promiseLabe.text = "User Was Not Assigned a Promise This Week"
                    cell.statusImageView.isHidden = true
                    cell.statusLabel.isHidden = true
                    cell.progressView.progress = 0.0
                    return
                }
                
                let snapVal = snapShot.value as! [String: String]
                let keys = snapVal.keys
                
                DispatchQueue.main.async {
                    var completion: Float = 0
                    
                    for key in keys {
                        let val = snapVal[key]
                        if val == "2" {
                            completion += 1
                        }
                    }
                    
                    if completion < 7 {
                        cell.statusImageView.image = UIImage(named: "incomplete")
                        cell.statusLabel.text = "Incomplete!"
                        cell.statusLabel.textColor = .darkGray
                    } else {
                        cell.statusImageView.image = UIImage(named: "complete")
                        cell.statusLabel.text = "Complete!"
                        cell.statusLabel.textColor = .green
                    }
                    
                    cell.progressView.progress = completion / 7.0
                    
                    cell.statusImageView.isHidden = false
                    cell.statusLabel.isHidden = false
                    cell.promiseLabe.text = snapVal["content"]
                    
                    if self.latch {
                        collectionView.reloadData()
                        self.latch = false
                    }
                }
                
            })
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
