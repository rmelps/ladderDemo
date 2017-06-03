//
//  ViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 5/31/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MainMenuViewController: UIViewController, UITextFieldDelegate {
    
    // Button properties
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // ImageView properties
    @IBOutlet weak var rockyImageView: UIImageView!
    @IBOutlet weak var mickeyImageView: UIImageView!
    
    // Visual Effect properties
    @IBOutlet weak var rockyVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var mickeyVisualEffectView: UIVisualEffectView!
    
    // Popup views
    @IBOutlet var signInPopupView: UIView!
    @IBOutlet var signUpPopupView: UIView!
    var currentView: UIView?
    
    // Sign In fields
    @IBOutlet weak var signInEmailTextField: UITextField!
    @IBOutlet weak var signInPasswordTextField: UITextField!
    
    // Button constraints
    @IBOutlet weak var signInButtonVertConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonVertConstraint: NSLayoutConstraint!
    var startConHeight: CGFloat!
    
    // Grouping stackview objects to save space
    var imageViews = [UIImageView]()
    var effectViews = [UIVisualEffectView]()
    var textFields = [UITextField]()
    
    // Sign Up fields
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userSwitch: UISwitch!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpAndEnterButton: UIButton!
    
    // FIRDatabase and Profile References
    var userDBRef: FIRDatabaseReference!
    var coachDBRef: FIRDatabaseReference!
    var signedInUser: User?
    var coachSignedIn: Bool!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startConHeight = UIScreen.main.bounds.height / 4 - (signInButton.bounds.height / 2)
        
        signInButtonVertConstraint.constant = startConHeight
        signUpButtonVertConstraint.constant = startConHeight
        
        imageViews.append(rockyImageView)
        imageViews.append(mickeyImageView)
        effectViews.append(rockyVisualEffectView)
        effectViews.append(mickeyVisualEffectView)
        
        textFields.append(emailAddressTextField)
        textFields.append(firstNameTextField)
        textFields.append(lastNameTextField)
        textFields.append(passwordTextField)
        textFields.append(confirmPasswordTextField)
        
        textFields.append(signInEmailTextField)
        textFields.append(signInPasswordTextField)
        
        let inSize = CGSize(width: UIScreen.main.bounds.width * 0.90, height: UIScreen.main.bounds.width * 0.90)
        let upSize = CGSize(width: UIScreen.main.bounds.width * 0.90, height: UIScreen.main.bounds.width * 1.3)
        signInPopupView.frame = CGRect(origin: CGPoint.zero, size: inSize)
        signUpPopupView.frame = CGRect(origin: CGPoint.zero, size: upSize)
        
        
        for effect in effectViews {
            effect.layer.cornerRadius = 3.0
        }
        
        for field in textFields {
            field.delegate = self
            field.returnKeyType = .done
            field.keyboardType = .emailAddress
        }
        
        passwordTextField.isSecureTextEntry = true
        signInPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        userLabel.text = "User"
        userSwitch.isOn = false
        userSwitch.tintColor = UIColor.blue
        
        userDBRef = FIRDatabase.database().reference().child("users")
        coachDBRef = FIRDatabase.database().reference().child("coaches")
        coachSignedIn = false
        
    }
    
    override func viewWillLayoutSubviews() {
        for image in imageViews {
            image.layer.borderWidth = 5.0
            image.layer.borderColor = UIColor.blue.cgColor
            image.layer.cornerRadius = 7.0
            image.layer.masksToBounds = true
        }
    }
    @IBAction func didSetSwitch(_ sender: UISwitch) {
        if sender.isOn {
            userLabel.text = "Coach"
        } else {
            userLabel.text = "User"
        }
    }
    @IBAction func willSignUp(_ sender: UIButton) {
        
        for textField in textFields {
            textField.resignFirstResponder()
        }
        
        guard !emailAddressTextField.text!.isEmpty, !firstNameTextField.text!.isEmpty, !lastNameTextField.text!.isEmpty, !passwordTextField.text!.isEmpty, !confirmPasswordTextField.text!.isEmpty else {
            return
        }
        
        if let email = emailAddressTextField.text, let first = firstNameTextField.text, let last = lastNameTextField.text, let password = passwordTextField.text, let confirm = confirmPasswordTextField.text {
            
            if password == confirm {
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                    if error == nil {
                        sender.isEnabled = false
                        var dbRef = FIRDatabaseReference()
                        if self.userSwitch.isOn {
                            dbRef = self.coachDBRef
                            self.signedInUser = Coach(uid: user!.uid, email: user!.email!, firstName: first, lastName: last)
                            self.coachSignedIn = true
                        } else {
                            dbRef = self.userDBRef
                            self.signedInUser = User(uid: user!.uid, email: user!.email!, firstName: first, lastName: last)
                            self.coachSignedIn = false
                        }
                        let personalRef = dbRef.child(user!.uid)
                        personalRef.setValue(self.signedInUser?.toAny())
                        self.animateOut()
                    } else {
                        print(error?.localizedDescription ?? "description not found")
                        let ac = UIAlertController(title: "Error!", message: error?.localizedDescription, preferredStyle: .alert)
                        let confirm = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                        })
                        ac.addAction(confirm)
                        self.present(ac, animated: true, completion: nil)
                    }
                })
            } else {
                print("passwords are not the same!")
                let ac = UIAlertController(title: "Error!", message: "Passwords are not the same!", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                })
                ac.addAction(confirm)
                self.present(ac, animated: true, completion: nil)
            }
            
        } else {
            print("could not create user")
            let ac = UIAlertController(title: "Error!", message: "Could not create user!", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            })
            ac.addAction(confirm)
            self.present(ac, animated: true, completion: nil)
        }
        
    }
    @IBAction func willSignIn(_ sender: UIButton) {
        
        for textField in textFields {
            textField.resignFirstResponder()
        }
        
        guard !signInEmailTextField.text!.isEmpty, !signInPasswordTextField.text!.isEmpty else {
            return
        }
        
        if let email = signInEmailTextField.text, let password = signInPasswordTextField.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user:FIRUser?, error:Error?) in
                if error == nil {
                    sender.isEnabled = false
                    self.userDBRef.observeSingleEvent(of: .value, with: { (snapShot: FIRDataSnapshot) in
                        if snapShot.hasChild(user!.uid) {
                            self.userDBRef.child(user!.uid).observeSingleEvent(of: .value, with: { (snapShot:FIRDataSnapshot) in
                                // sign in user
                                self.signedInUser = User(userData: user!, snapShot: snapShot)
                                print("Welcome \(self.signedInUser!.firstName)")
                                self.coachSignedIn = false
                                self.animateOut()
                            })
                        } else {
                            self.coachDBRef.observeSingleEvent(of: .value, with: { (snapShot: FIRDataSnapshot) in
                                if snapShot.hasChild(user!.uid) {
                                    self.coachDBRef.child(user!.uid).observeSingleEvent(of: .value, with: { (snapShot:FIRDataSnapshot) in
                                        // sign in coach
                                        self.signedInUser = Coach(userData: user!, snapShot: snapShot)
                                        print("Welcome \(self.signedInUser!.firstName)")
                                        self.coachSignedIn = true
                                        self.animateOut()
                                    })
                                } else {
                                    print("could not find user or coach in database")
                                }
                            })
                        }
                    })
                } else {
                    print(error?.localizedDescription ?? "no error description found")
                    let ac = UIAlertController(title: "Error!", message: error?.localizedDescription, preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                    })
                    ac.addAction(confirm)
                    self.present(ac, animated: true, completion: nil)
                }
            })
        }
    }
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        for field in textFields {
            field.resignFirstResponder()
        }
    }
    @IBAction func onTap2(_ sender: UITapGestureRecognizer) {
        for field in textFields {
            field.resignFirstResponder()
        }
    }
    
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        currentView = signInPopupView
        
        
        self.view.addSubview(currentView!)
        currentView!.alpha = 0
        
        signInButton.isEnabled = false
        signUpButton.isEnabled = false
        
        currentView!.center = self.view.center
        
        currentView!.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        
        self.signInButtonVertConstraint.constant = -100
        self.signUpButtonVertConstraint.constant = -100
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(MainMenuViewController.animateOut))
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(MainMenuViewController.animateOut))
        
        UIView.animate(withDuration: 0.5, animations: { 
            self.currentView!.alpha = 1
            self.currentView!.transform = CGAffineTransform.identity
            self.view.layoutIfNeeded()
        }) { (_) in
            self.mickeyVisualEffectView.addGestureRecognizer(tapGestureRecognizer1)
            self.rockyVisualEffectView.addGestureRecognizer(tapGestureRecognizer2)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        currentView = signUpPopupView
        
        
        self.view.addSubview(currentView!)
        currentView!.alpha = 0
        
        signInButton.isEnabled = false
        signUpButton.isEnabled = false
        
        currentView!.center = self.view.center
        
        currentView!.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        
        self.signInButtonVertConstraint.constant = -100
        self.signUpButtonVertConstraint.constant = -100
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(MainMenuViewController.animateOut))
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(MainMenuViewController.animateOut))
        
        UIView.animate(withDuration: 0.5, animations: {
            self.currentView!.alpha = 1
            self.currentView!.transform = CGAffineTransform.identity
            self.view.layoutIfNeeded()
        }) { (_) in
            self.mickeyVisualEffectView.addGestureRecognizer(tapGestureRecognizer1)
            self.rockyVisualEffectView.addGestureRecognizer(tapGestureRecognizer2)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showCoachScreenSegue":
            let tabVC = segue.destination as! CoachTabBarViewController
            tabVC.coachDBRef = self.coachDBRef
            tabVC.userDBRef = self.userDBRef
            tabVC.signedInCoach = self.signedInUser as! Coach
        case "showUserScreenSegue":
            let tabVC = segue.destination as! UserTabBarViewController
            tabVC.coachDBRef = self.coachDBRef
            tabVC.userDBRef = self.userDBRef
            tabVC.signedInUser = self.signedInUser
        default:
            break
        }
    }
    
    func animateOut() {
        
        if let view = currentView {
            
            if signedInUser == nil {
                signInButtonVertConstraint.constant = startConHeight
                signUpButtonVertConstraint.constant = startConHeight
            }
        
            UIView.animate(withDuration: 0.4, animations: {
                view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.view.layoutIfNeeded()
                view.alpha = 0
            }) { (_) in
                view.removeFromSuperview()
                self.currentView = nil
                self.signInButton.isEnabled = true
                self.signUpButton.isEnabled = true
                
                if self.signedInUser != nil {
                    UIView.animate(withDuration: 3.0, animations: {
                        if self.coachSignedIn {
                            self.mickeyVisualEffectView.alpha = 0
                        } else {
                            self.rockyVisualEffectView.alpha = 0
                        }
                    }, completion: { (_) in
                        
                        let delayInSeconds = 1.0
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                            if self.coachSignedIn {
                                self.performSegue(withIdentifier: "showCoachScreenSegue", sender: self)
                            } else {
                                self.performSegue(withIdentifier: "showUserScreenSegue", sender: self)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.currentView!.center.y = self.view.center.y - self.currentView!.frame.height / 4
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.currentView!.center.y = self.view.center.y
        }
    }
    
}

