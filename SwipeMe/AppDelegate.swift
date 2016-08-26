//
//  AppDelegate.swift
//  SwipeMe
//
//  Created by Brian Ramirez on 8/17/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import SwiftSpinner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if(Reachability.isConnectedToNetwork()){
            
            //Firebase app configuration
            FIRApp.configure()
        
            //Google Sign in configuration
            GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
            GIDSignIn.sharedInstance().delegate = self
            
        }
        
        //Make status bar pretty
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
        return true
    }
    
    //Google sign in setup
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
            sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
            annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
        
    }
    
    //Google sign in setup
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
        SwiftSpinner.showWithDelay(2.0, title: "Signing In..")
            if let error = error {
                 SwiftSpinner.show("Failed to sign in. Try again later.", animated: false)
                print(error.localizedDescription)
                return
            }
            let authentication = user.authentication
            let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                accessToken: authentication.accessToken)
           
            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                 SwiftSpinner.hide()
            }
    }
    
    //Google sing in setup
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }
    
    
   
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
   

}

