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
        
        
        
        for image in imageViews {
            image.layer.borderWidth = 5.0
            image.layer.borderColor = UIColor.blue.cgColor
            image.layer.cornerRadius = 3.0
            image.layer.masksToBounds = true
        }
        
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
        userSwitch.tintColor = .blue
        
        userDBRef = FIRDatabase.database().reference().child("users")
        coachDBRef = FIRDatabase.database().reference().child("coaches")
        
    }
    @IBAction func didSetSwitch(_ sender: UISwitch) {
        if sender.isOn {
            userLabel.text = "Coach"
        } else {
            userLabel.text = "User"
        }
    }
    @IBAction func willSignUp(_ sender: UIButton) {
        print("signing up...")
        
        guard !emailAddressTextField.text!.isEmpty, !firstNameTextField.text!.isEmpty, !lastNameTextField.text!.isEmpty, !passwordTextField.text!.isEmpty, !confirmPasswordTextField.text!.isEmpty else {
            print("fill in the fields!")
            return
        }
        
        if let email = emailAddressTextField.text, let first = firstNameTextField.text, let last = lastNameTextField.text, let password = passwordTextField.text, let confirm = confirmPasswordTextField.text {
            
            print("all fields populated")
            
            if password == confirm {
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                    if error == nil {
                        self.signedInUser = User(uid: user!.uid, email: user!.email!, firstName: first, lastName: last)
                        var dbRef = FIRDatabaseReference()
                        if self.userSwitch.isOn {
                            dbRef = self.coachDBRef
                        } else {
                            dbRef = self.userDBRef
                        }
                        let personalRef = dbRef.child(user!.uid)
                        personalRef.setValue(self.signedInUser?.toAny())
                    } else {
                        print(error?.localizedDescription ?? "description not found")
                    }
                })
            } else {
                print("passwords are not the same!")
            }
            
        } else {
            print("could not create user")
        }
        
    }
    @IBAction func willSignIn(_ sender: UIButton) {
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
    
    func animateOut() {
        
        if let view = currentView {
            signInButtonVertConstraint.constant = startConHeight
            signUpButtonVertConstraint.constant = startConHeight
        
            UIView.animate(withDuration: 0.4, animations: {
                view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.view.layoutIfNeeded()
                view.alpha = 0
            }) { (_) in
                view.removeFromSuperview()
                self.currentView = nil
                self.signInButton.isEnabled = true
                self.signUpButton.isEnabled = true
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

