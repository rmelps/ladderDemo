//
//  UserInViewController.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseAuth
import Photos
import FirebaseStorage
import FirebaseDatabase


class UserInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var homeScreenImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    // File storage references
    var storage: FIRStorage!
    var storageRef: FIRStorageReference!
    var imagesRef: FIRStorageReference!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    var userTabViewController: UserTabBarViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTabViewController = tabBarController as! UserTabBarViewController
        
        userNameLabel.text = "\(userTabViewController.signedInUser.firstName)"
        
        applyMotionEffect(toView: homeScreenImageView, magnitude: 40)
        applyMotionEffect(toView: userNameLabel, magnitude: -15)
        applyMotionEffect(toView: welcomeLabel, magnitude: -15)
        applyMotionEffect(toView: changePhotoButton, magnitude: -15)
        applyMotionEffect(toView: logOutButton, magnitude: -15)
        applyMotionEffect(toView: profilePicView, magnitude: -15)
        
        storage = FIRStorage.storage()
        storageRef = storage.reference()
        imagesRef = storageRef.child("profileImages")
        
        activityIndicator.startAnimating()
        
        
        
        if userTabViewController.signedInUser.photoPath != "nil" {
            
            // Create a reference to the file that will be downloaded
            let reference = storage.reference(forURL: userTabViewController.signedInUser.photoPath)
            
            // Download image at path to local memory with defined maximum size
            reference.data(withMaxSize: 10 * 1024 * 1024) { (data:Data?, error:Error?) in
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                if let error = error {
                    print(error.localizedDescription)
                }
                if let data = data {
                    self.profilePicView.image = UIImage(data: data)!
                }
            }
        } else {
            self.profilePicView.image = UIImage(named: "default-avatar")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profilePicView.layer.cornerRadius = 4.0
        profilePicView.clipsToBounds = true
        
        self.view.setNeedsLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "userLogOutSegue":
            let vc = segue.destination as! MainMenuViewController
            for field in vc.textFields {
                field.text = ""
            }
        default:
            break
        }
    }
    
    @IBAction func changePhotoButtonPressed(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .savedPhotosAlbum
            
            self.present(imagePicker, animated: true, completion: nil)
            
        } else {
            print("Photo album not available")
        }
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        self.performSegue(withIdentifier: "userLogOutSegue", sender: self)
    }
    
    func applyMotionEffect(toView view:UIView, magnitude: Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        view.addMotionEffect(xMotion)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = UIImage()
        image = info[UIImagePickerControllerEditedImage] as! UIImage
        profilePicView.image = image
        dismiss(animated: true) {
            let user = self.userTabViewController.signedInUser
            let imageToUpload = UIImageJPEGRepresentation(image, 0.5)
            let ref = self.imagesRef.child(user!.uid)
            
            ref.put(imageToUpload!, metadata: nil, completion: { (metaData:FIRStorageMetadata?, error:Error?) in
                guard let metaData = metaData else {
                    let ac = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    ac.addAction(confirm)
                    self.present(ac, animated: true, completion: nil)
                    return
                }
                
                let downloadURL = "\(metaData.downloadURL()!)"
                
                user?.photoPath = downloadURL
                
                let dbRef = self.userTabViewController.userDBRef.child(user!.uid)
                
                dbRef.setValue(user?.toAny())
                
                
            })
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

}
