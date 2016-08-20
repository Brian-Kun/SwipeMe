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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       getPhoneNumber("tanasn")
        
    }
    
    func uploadPhoneNumber(phonenumber : String!, UserID : String!){
    
        let phoneNumbersDictionary : [String : AnyObject] = ["phoneNumber" : phonenumber , "userId" : UserID]
        let databaseReference = FIRDatabase.database().reference()
        databaseReference.child("Phone_Numbers").child(UserID).setValue(phoneNumbersDictionary)
    
    }
    
    
    func getPhoneNumber( UserID: String!){
        
        let databaseReference =  FIRDatabase.database().reference().child("Phone_Numbers").child(UserID)
        // only need to fetch once so use single event
        
        databaseReference.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.exists() {
                print ("Phone Number not found for this user id")
                return
            }
            
            if let phoneNumberValue = snapshot.value!["phoneNumber"] as? String {
                print(phoneNumberValue)
            }
        })

        
    }
    

    
}
