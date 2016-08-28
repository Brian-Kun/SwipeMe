//
//  ProfileViewController.swift
//  SwipeMe
//
//  Created by Tanaya Asnani on 8/18/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit
import FirebaseAuth
import JSSAlertView
import FirebaseInvites
import GoogleSignIn
import MessageUI

class ProfileViewController: UIViewController,FIRInviteDelegate,GIDSignInUIDelegate,MFMailComposeViewControllerDelegate  {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!

    @IBOutlet weak var feedbackBtn: UIButton!
    
    
    @IBOutlet weak var inviteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!Reachability.isConnectedToNetwork()){
            displayNoInternetAlert()
        }
        
        self.title = "Profile"
        
        //Make user image
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
        
        //Check if user is logged in. (Migth remove )
        if let user = FIRAuth.auth()?.currentUser {
            
            //fetch for user image,name,email, and uid
            let name = user.displayName!
            let email = user.email
            let photoUrl = user.photoURL
            
            //Display User info
            nameLbl.text = name
            emailLbl.text = email
            userImage.image = UIImage(data: ( NSData(contentsOfURL: photoUrl!))! )
        }

        
    }
    

    
    @IBAction func inviteTapped(sender: UIButton) {
        
        if let invite = FIRInvites.inviteDialog() {
            invite.setInviteDelegate(self)
            
            
            invite.setMessage("Check this app out! It's called Swpr")
            invite.setTitle("Swpr invite! ")
            invite.setDeepLink("https://cq83n.app.goo.gl/qbvQ")
            invite.setCallToActionText("Install!")
            invite.setCustomImage("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
            invite.open()
        }
        
    }
    

    @IBAction func logOutBtnPressed(sender: UIButton) {
        print("User is being logged out...")
        try! FIRAuth.auth()!.signOut()
        
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LogInScreen") as UIViewController
        
        self.presentViewController(viewController, animated: true, completion: nil)
       
    }
    //let the mailview controller appear when the send feedback button is pressed
    @IBAction func feedbackBtnPressed(sender: UIButton) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            displayAlert("Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
        }
        
    }
    //set mail vie controller attributes
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["info.swipeme@gmail.com"])
        mailComposerVC.setSubject("Swpr Feedback ")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
        
    //Displays UI arelt with title, message and "Okay" button
    func displayAlert(title:String, message: String){
        let alertView = JSSAlertView().show(
            self,
            title: title,
            text: message,
            buttonText: "Okay",
            color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0),
            iconImage: UIImage(named: "idea"))
        alertView.setTextTheme(.Light)
    }
    //method to dismiss mailview controller once sent
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
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
    func inviteFinishedWithInvitations(invitationIds: [AnyObject], error: NSError?) {
        if let error = error {
            print("Failed: " + error.localizedDescription)
        } else {
            print("Invitations sent")
        }
    }
   

}
