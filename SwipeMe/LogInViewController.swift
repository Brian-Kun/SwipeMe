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
import JSSAlertView
import SwiftSpinner

class LogInViewController: UIViewController, GIDSignInUIDelegate{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Reachability.isConnectedToNetwork()){
            print("Internet Connection Found")
            //Firebase Login setup
            GIDSignIn.sharedInstance().uiDelegate = self
            
            //Authentication listener that waits until the state changes
            FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
                if let user = user {
                    
                    let triggerTime1 = (Int64(NSEC_PER_SEC) * 2)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime1), dispatch_get_main_queue(), { () -> Void in
                        SwiftSpinner.show("Welcome, \(user.displayName!)", animated: false)
                    })
                    
                    let triggerTime = (Int64(NSEC_PER_SEC) * 4)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                        SwiftSpinner.hide()
                        //Once the state changes to logged in, it moves the user to the next screen
                        self.performSegueWithIdentifier("userLoggedInSegue", sender: self)
                    })
                }
            }
        }else{
            print("Internet Connection NOT Found")
        }
            
       
        
    }//End of viewDidLoad()
    
    override func viewDidAppear(animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            print("User \((user.displayName)!) is already signed in! Moving to next screen!")
            SwiftSpinner.show("Signin In..", animated: true)
        }
    }
    
    

    @IBAction func googleBtnPressed(sender: UIButton) {
        if(Reachability.isConnectedToNetwork()){
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().signIn();
        }else{
            SwiftSpinner.show("Connecting to internet", animated: true)
            let triggerTime = (Int64(NSEC_PER_SEC) * 2)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                 SwiftSpinner.show("Failed to connect.", animated: false)
            })
        }
    }


}

