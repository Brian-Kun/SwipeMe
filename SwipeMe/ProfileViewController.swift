//
//  ProfileViewController.swift
//  SwipeMe
//
//  Created by Tanaya Asnani on 8/18/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var uidLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile"
        
        //Make user image
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
        
        //Check if user is logged in. (Migth remove )
        if let user = FIRAuth.auth()?.currentUser {
            
            //fetch for user image,name,email, and uid
            let name = user.displayName
            let email = user.email
            let photoUrl = user.photoURL
            let uid = user.uid
            
            //Display User info
            nameLbl.text = name
            emailLbl.text = email
            uidLbl.text = uid
            userImage.image = UIImage(data: ( NSData(contentsOfURL: photoUrl!))! )
        }

        
    }

    

    @IBAction func logOutBtnPressed(sender: UIButton) {
        print("User is being logged out...")
        try! FIRAuth.auth()!.signOut()
        performSegueWithIdentifier("userLoggedOutSegue", sender: self)
        
       
    }
   

}
