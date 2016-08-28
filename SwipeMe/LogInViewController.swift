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
        
        //Check fot internet before doing anything
        if(Reachability.isConnectedToNetwork()){
            
            //Firebase Login setup
            GIDSignIn.sharedInstance().uiDelegate = self
            
            //Authentication listener that waits until the state changes
            FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
                if let user = user {
                    let triggerTime1 = (Int64(NSEC_PER_SEC) * 4)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime1), dispatch_get_main_queue(), { () -> Void in
                        print("\(user.displayName) is all good. moving to next screen")
                        self.performSegueWithIdentifier("userLoggedInSegue", sender: self)

                    })
                }
            }
        }
    }//End of viewDidLoad()
    
    override func viewDidAppear(animated: Bool) {
        //If this is not the first time a user logs in, we automatically log them in.
        if let user = FIRAuth.auth()?.currentUser {
            print("\(user.displayName!) has alreafy signed in, moving on...)")
            GIDSignIn.sharedInstance().signIn()
        }
       
    }//end of viewDidAppear()
    

    @IBAction func googleBtnPressed(sender: UIButton) {
        //When log in button is taopped, log users in, if no internet is found, a Spinner will display it.
        if(Reachability.isConnectedToNetwork()){
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().signIn();
        }else{
            SwiftSpinner.show("Connecting to internet...", animated: true)
            let triggerTime = (Int64(NSEC_PER_SEC) * 2)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                 SwiftSpinner.show("Failed to connect. Try again later.", animated: false)
            })
            let triggerTime1 = (Int64(NSEC_PER_SEC) * 4)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime1), dispatch_get_main_queue(), { () -> Void in
                SwiftSpinner.hide()
            })
        }
    }
    
    


}

