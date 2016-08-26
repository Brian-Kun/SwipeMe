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
    
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Reachability.isConnectedToNetwork()){
            
            //Firebase Login setup
            GIDSignIn.sharedInstance().uiDelegate = self
            
            //Authentication listener that waits until the state changes
            FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
                if let user = user {
                    self.loginIndicator.stopAnimating()
                    //Once the state changes to logged in, it moves the user to the next screen
                    print("User \((user.displayName)!) is already signed in! Moving to next screen!")
                    self.performSegueWithIdentifier("userLoggedInSegue", sender: self)
                } 
            }
            
        }else{
            displayNoInternetAlert()
        }
        
        
    }//End of viewDidLoad()
    
    override func viewDidAppear(animated: Bool) {
        if(!Reachability.isConnectedToNetwork()){
            displayNoInternetAlert()
        }
    }
    
    

    @IBAction func googleBtnPressed(sender: UIButton) {
        if(Reachability.isConnectedToNetwork()){
            loginIndicator.startAnimating()
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().signIn();
        }else{
            displayNoInternetAlert()
        }
        
    }
    
    func displayNoInternetAlert(){
        let alertView = JSSAlertView().show(
            self,
            title: "Oh 💩...",
            text: "Looks like there is no internet. Connect to a network and relauch the app.",
            buttonText: "FML😫 Okay",
            color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0),
            iconImage: UIImage(named: "noInternet"))
        alertView.setTextTheme(.Light)
    }


}

