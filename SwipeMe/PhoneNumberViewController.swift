//
//  PhoneNumberViewController.swift
//  SwipeMe
//
//  Created by Tanaya Asnani on 8/20/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import JSSAlertView
import SwiftSpinner


class PhoneNumberViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    
    //Get firebase user object
    let user = FIRAuth.auth()?.currentUser
    
    var pageImages:NSArray!
    var pageViewController:UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        
        //Make user image round
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
        
        //Add gesture recognizer to dismiss keyboard when you tap anywhere on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhoneNumberViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Check internet connection
        if(Reachability.isConnectedToNetwork()){
            
            if let user = FIRAuth.auth()?.currentUser {
                
                //Display loading spinner
                let triggerTime = (Int64(NSEC_PER_SEC) * 1)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    SwiftSpinner.show("Loading information", animated: true)
                })
                
                //Get user phone number from db
                getPhoneNumber(user.uid)
                
                //fetch for user image,name,email, and uid
                let name = user.displayName
                let email = user.email
                let photoUrl = user.photoURL
                
                //Display User info
                nameLbl.text = name
                emailLbl.text = email
                userImage.image = UIImage(data: ( NSData(contentsOfURL: photoUrl!))! )
            }
            
        }else{
            //Is there is no internet, display that
            displayNoInternetAlert()
        }
        
        
        
    }
    
    
    @IBAction func continueBtnPressed(sender: UIButton) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let displayedIntro = userDefaults.boolForKey("displayedIntro")

        getPhoneNumber(user?.uid)
        
        //Check for correct phone number
        if(phoneTextField.text?.characters.count == 0){
            displayAlert("Quick Thing...", message: "You forgot to input your phone number. We need your phone number to help you contact those that want a meal swipe. We DO NOT share your phone number with any third party company or anything like that.")
        }
        else if(phoneTextField.text?.characters.count != 10){
            displayAlert("😅😅😅", message: "Hey! It looks like that phone number is not valid. Remember just input the phone number without spaces dashes, or country code. If your number is (978)-885-5214, input it like this 9788855214")

        }
        else{
            if(getPhoneNumber(user?.uid).characters.count == 0){
                uploadPhoneNumber(phoneTextField.text)
            }
            
            if(displayedIntro){
                performSegueWithIdentifier("userConfirmedSegue", sender: self)
            }else{
                self.displayIntroView()            }
            
        }
    }//end of btnPressesd()
    
    func uploadPhoneNumber(phonenumber : String!){
        
        let phoneNumbersDictionary : [String : AnyObject] = ["phoneNumber" : phonenumber]
        let databaseReference = FIRDatabase.database().reference()
        databaseReference.child("Phone Numbers").child(user!.uid).setValue(phoneNumbersDictionary)
        
    }
    
    
    func getPhoneNumber( userUID: String!) -> String{
        
        var result = ""
        
        let databaseReference =  FIRDatabase.database().reference().child("Phone Numbers").child(userUID)
        // only need to fetch once so use single event
        
        databaseReference.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.exists() {
                let triggerTime2 = (Int64(NSEC_PER_SEC) * 3)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime2), dispatch_get_main_queue(), { () -> Void in
                    SwiftSpinner.show("Please Add Phone Number", animated: false)
                })
                
                let triggerTime = (Int64(NSEC_PER_SEC) * 6)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    SwiftSpinner.hide()
                })
                return
            }
            
            if let phoneNumberValue = snapshot.value!["phoneNumber"] as? String {
                
                result = phoneNumberValue
                let triggerTime2 = (Int64(NSEC_PER_SEC) * 3)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime2), dispatch_get_main_queue(), { () -> Void in
                     SwiftSpinner.show("User Information Loaded", animated: false)
                })
                
               
                let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                   SwiftSpinner.hide()
                })

                let triggerTime1 = (Int64(NSEC_PER_SEC) * 4)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime1), dispatch_get_main_queue(), { () -> Void in
                    if(result.characters.count == 10){
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        let displayedIntro = userDefaults.boolForKey("displayedIntro")
                        if(displayedIntro){
                            self.performSegueWithIdentifier("userConfirmedSegue", sender: self)
                        }else{
                           self.displayIntroView()
                        }
                    }
                })
                
            }
        })
        SwiftSpinner.hide()
        return result
        
    }
    
    
    func displayAlert(title:String, message: String){
        let alertView = JSSAlertView().show(
            self,
            title: title,
            text: message,
            buttonText: "Okay",
            color: UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0),
            iconImage: UIImage(named: "phoneNumber"))
        alertView.setTextTheme(.Light)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
    
    //Start of code for introview ---------------------------------------------------------------------------------
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! ContentHolderViewController
        var index = viewController.pageIndex as Int
        
        if(index == 0 || index == NSNotFound){
            return nil
        }
        
        index -= 1
        
        return self.pageAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        let viewController = viewController as! ContentHolderViewController
        var index = viewController.pageIndex as Int
        
        if((index == NSNotFound)){
            return nil
        }
        
        index += 1
        
        if(index == pageImages.count){
            return nil
        }
        
        return self.pageAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageAtIndex(index: Int) -> ContentHolderViewController{
        
        let contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("contentHolder") as! ContentHolderViewController
        
        contentViewController.imageName = pageImages[index] as! String
        contentViewController.pageIndex = index
        
        return contentViewController
    }
    
    func displayIntroView(){
        self.pageImages = NSArray(objects: "1","2","3","4","5","6")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("pageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        let initialContenViewController = self.pageAtIndex(0) as ContentHolderViewController
        
        let viewControllers = NSArray(object: initialContenViewController)
        
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    //End Code for introview ------------------------------------------------------------------------------------------------
    
    

    
}
