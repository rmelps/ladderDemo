//
//  AssignPromiseTableViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/2/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AssignPromiseTableViewController: UITableViewController {
    
    var promiseStore = PromiseStore()
    let reuseIdentifier = "promiseCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPresets()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backgroundImage = UIImage(named: "coachHome")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = imageView
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return promiseStore.allPromises.count
    }
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let title = "Add New Promise"
        let message = "Create a Custom Promise"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { (action:UIAlertAction) in
            
            let textField = alert.textFields![0] as UITextField
            
            if let text = textField.text {
                let newPromise = self.promiseStore.createPromise(content: text)
                if let index = self.promiseStore.allPromises.index(of: newPromise) {
                     let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
            
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter New Promise"
            textField.autocapitalizationType = .sentences
            textField.autocorrectionType = .yes
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PromiseCell
        
        cell.backgroundColor = UIColor(white: 0.45, alpha: 0.4)
        
        let promise = promiseStore.allPromises[indexPath.row]
        
        cell.promiseLabel.text = promise.content

        return cell
    }
    
    func createPresets() {
        
        let p1 = Promise(content: "Drink 8 Cups of Water")
        let p2 = Promise(content: "Run a mile")
        let p3 = Promise(content: "Drink Tea instead of Beer...Sometimes")
        let p4 = Promise(content: "Get 8 Hours of Sleep")
        let p5 = Promise(content: "Take the Stairs at Work")
        
        promiseStore.allPromises.append(p1)
        promiseStore.allPromises.append(p2)
        promiseStore.allPromises.append(p3)
        promiseStore.allPromises.append(p4)
        promiseStore.allPromises.append(p5)
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            promiseStore.allPromises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action:UITableViewRowAction, indexPath: IndexPath) in
            self.promiseStore.allPromises.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        delete.backgroundColor = .red
        
        let assign = UITableViewRowAction(style: .default, title: "Assign") { (action:UITableViewRowAction, indexPath: IndexPath) in
            
            let tabVC = self.tabBarController as! CoachTabBarViewController
            
            if let user = tabVC.selectedUser {
                let nextSunday = tabVC.get(direction: .Next, "Sunday", considerToday: false)
                let lastSunday = tabVC.get(direction: .Previous, "Sunday", considerToday: true)
                
                var message = String()
                var confirmNext = UIAlertAction()
                var confirmCurrent = UIAlertAction()
                var ac = UIAlertController()
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) in
                })
                
                tabVC.promiseDBRef.child("\(lastSunday)").observeSingleEvent(of: .value, with: { (snapShot:FIRDataSnapshot) in
                    if snapShot.hasChild(user.uid) {
                        message = "Do you want to assign this promise to \(user.firstName) \(user.lastName) for next week?"
                        ac = UIAlertController(title: "Assign Promise", message: message, preferredStyle: .alert)
                        
                        confirmNext = UIAlertAction(title: "Confirm", style: .default, handler: { (action:UIAlertAction) in
                            
                            let promise = self.promiseStore.allPromises[indexPath.row]
                            
                            tabVC.promiseDBRef.child("\(nextSunday)").child(user.uid).setValue(promise.toAny())
                            
                        })
                        ac.addAction(confirmNext)
                        ac.addAction(cancel)
                        self.present(ac, animated: true, completion: nil)
                    } else {
                        message = "\(user.firstName) \(user.lastName) has not been assigned a promise for this week. Assign promise to the current week or next week?"
                        ac = UIAlertController(title: "Assign Promise", message: message, preferredStyle: .alert)
                        confirmNext = UIAlertAction(title: "Next Week", style: .default, handler: { (action:UIAlertAction) in
                            
                            let promise = self.promiseStore.allPromises[indexPath.row]
                            
                            tabVC.promiseDBRef.child("\(nextSunday)").child(user.uid).setValue(promise.toAny())
                            
                        })
                        confirmCurrent = UIAlertAction(title: "Current Week", style: .default, handler: { (action:UIAlertAction) in
                            let promise = self.promiseStore.allPromises[indexPath.row]
                            
                            tabVC.promiseDBRef.child("\(lastSunday)").child(user.uid).setValue(promise.toAny())
                        })
                        ac.addAction(confirmNext)
                        ac.addAction(confirmCurrent)
                        ac.addAction(cancel)
                        self.present(ac, animated: true, completion: nil)
                    }
                })
            } else {
                let ac = UIAlertController(title: "No User Selected", message: "Select a User under the User tab first", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "OK", style: .cancel, handler: { (action:UIAlertAction) in
                    
                })
                ac.addAction(confirm)
                self.present(ac, animated: true, completion: nil)
            }
            
        }
        assign.backgroundColor = UIColor(displayP3Red: 79/255, green: 199/255, blue: 113/255, alpha: 1.0)
        
        return [delete, assign]
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
