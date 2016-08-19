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
import FBSDKLoginKit

class LogInViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate  {
    
    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Get rid of this shit and do it in the view
        // Facebook Btn and Delegate
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view!.addSubview(loginButton)
      
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
    }
    
    
    //Facebook login with Firabase Auth
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error == error {
            //Something went wrong
            //TODO: Create error modals
            print(error)
        }
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                // Triple check everything in here
                print("Logged in with facebook")
                
            }
        
    }
    
    //Do nothing here, for now.
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //
    }
    

    @IBAction func googleBtnPressed(sender: UIButton) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn();
    }


}

