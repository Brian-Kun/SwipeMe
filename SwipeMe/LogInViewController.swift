//
//  ViewController.swift
//  SwipeMe
//
//  Created by Brian Ramirez on 8/17/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Get rid of this shit and do it in the view
        // Facebook Btn and Delegate
        loginButton.center = CGPointMake(320.0, 480.0)
        loginButton.delegate = self
        
        self.view!.addSubview(loginButton)
    }
    
    //Facebook login with Firabase Auth
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            //Something went wrong
            //TODO: Create error modals
            print(error)
        }else{
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                // Triple check everything in here
                print("Nigga we made it:")
                
            }
        }
    }
    
    //Do nothing here, for now.
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //
    }

}

