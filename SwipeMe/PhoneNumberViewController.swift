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


class PhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make user image round
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhoneNumberViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        if(Reachability.isConnectedToNetwork()){
            //Check if user is logged in. (Migth remove )
            if let user = FIRAuth.auth()?.currentUser {
                
                let triggerTime = (Int64(NSEC_PER_SEC) * 1)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    SwiftSpinner.show("Loading information", animated: true)
                })
                
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
            displayNoInternetAlert()
        }
        
        
        
    }
    
    
    @IBAction func continueBtnPressed(sender: UIButton) {
        
        
        getPhoneNumber(user?.uid)
        
        if(phoneTextField.text?.characters.count == 0){
            displayAlert("Quick Thing...", message: "You forgot to input your phone number. We need your phone number to help you contact those that want a meal swipe.")
        }
        else if(phoneTextField.text?.characters.count != 10){
            displayAlert("😅😅😅", message: "Hey! It looks like that phone number is not valid. Remember just input the phone number without spaces dashes, or country code.")

        }
        else{
            if(getPhoneNumber(user?.uid).characters.count == 0){
                uploadPhoneNumber(phoneTextField.text)
            }
            performSegueWithIdentifier("userConfirmedSegue", sender: self)
        }
    }
    
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
                        self.performSegueWithIdentifier("userConfirmedSegue", sender: self)
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
    

    
}
