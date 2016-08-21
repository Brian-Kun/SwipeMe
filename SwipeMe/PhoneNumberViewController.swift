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


class PhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPhoneNumber(user?.uid)
        
        //Check if user is logged in. (Migth remove )
        if let user = FIRAuth.auth()?.currentUser {
        
            //fetch for user image,name,email, and uid
            let name = user.displayName
            let email = user.email
            let photoUrl = user.photoURL
        
            //Display User info
            nameLbl.text = name
            emailLbl.text = email
            userImage.image = UIImage(data: ( NSData(contentsOfURL: photoUrl!))! )
        }
        
        
    }
    
    
    @IBAction func continueBtnPressed(sender: UIButton) {
        
        
        getPhoneNumber(user?.uid)
        
        if(phoneTextField.text?.characters.count == 0){
            displayAlert("Quick Thing...", message: "You forgot to input your phone number")
        }
        else if(phoneTextField.text?.characters.count != 10){
            displayAlert("Hey There!", message: "Phone number is not 10 characters")

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
                print ("Phone Number not found for this user id")
                return
            }
            
            if let phoneNumberValue = snapshot.value!["phoneNumber"] as? String {
                result = phoneNumberValue
                self.phoneTextField.text = result
                print("Phone number is \(result)")
            }
        })
        
        return result
        
    }
    
    
    func displayAlert(title:String, message: String){
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    
}
