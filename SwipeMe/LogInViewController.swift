//
//  ViewController.swift
//  SwipeMe
//
//  Created by Brian Ramirez on 8/17/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class LogInViewController: UIViewController, GIDSignInUIDelegate{
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase Login setup
        GIDSignIn.sharedInstance().uiDelegate = self
        
        //Authentication listener that waits until the state changes
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                //Once the state changes to logged in, it moves the user to the next screen
                print("User \((user.displayName)!) is already signed in! Moving to next screen!")
                self.performSegueWithIdentifier("userLoggedInSegue", sender: self)
            } else {
                
            }
        }
        
    }//End of viewDidLoad()
    
    

    @IBAction func googleBtnPressed(sender: UIButton) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn();
    }


}

