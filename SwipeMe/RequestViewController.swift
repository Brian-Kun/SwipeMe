//
//  RequestViewController.swift
//  SwipeMe
//
//  Created by Tanaya Asnani on 8/18/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import XLActionController
import JSSAlertView

class RequestTableViewController: UITableViewController {
    
    var requestArray = [Request]()
    
    let noReuqestImageView = UIImageView(image: UIImage(named: "noRequests")!)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        self.refreshControl?.addTarget(self, action: #selector(refreshTable), forControlEvents: UIControlEvents.ValueChanged)
        
        //Hide the tableview and display the noRequestImageView. We don't wanna show an empty tableview...
        tableView.backgroundColor = UIColor.lightGrayColor()
        tableView.separatorColor = UIColor.clearColor()
        noReuqestImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        view.addSubview(noReuqestImageView)
        noReuqestImageView.hidden = false
        
        
        
        //Navigation controller title
        self.title = "Meal Requests"
        
        //Adds the + button to the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: #selector(showPopUpForRequest))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        let size = 24.00
        let font = UIFont.boldSystemFontOfSize(CGFloat(size))
        let attributes = [NSFontAttributeName: font]
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, forState: .Normal)
      

        //Pulls data from database and updates it by adding it to the requestArray
        let databaseRef = FIRDatabase.database().reference()
        
        //Constantly refresh tableView when new requests are added
        databaseRef.child("Requests").queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            let displayName = snapshot.value!["displayName"] as! String
            let UID = snapshot.value!["UID"] as! String
            let createdAt = snapshot.value!["createdAt"] as! String
            let location = snapshot.value!["location"] as! String
            let photoURL = snapshot.value!["userPhotoURL"] as! String
            let comment = snapshot.value!["comment"] as! String
            let childAutoID = snapshot.key
            
            if self.requestIsOld(createdAt) {
                self.deleteRequestWithRequestID(childAutoID)
            } else{
            self.requestArray.insert(Request(displayName: displayName, UID: UID, createdAt: createdAt, location: location, userPhotoURL: photoURL, comment: comment,requestID: childAutoID), atIndex: 0)
            }
           
            self.tableView.reloadData()
        })
        
        //Constantly refresh tableView when requests are deleted
        databaseRef.child("Requests").queryOrderedByKey().observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            
            let childAutoID = snapshot.key
            
            if(self.requestArray.count != 0){
                for index in 0...self.requestArray.count-1{
                    if(self.requestArray[index].requestID == childAutoID){
                        self.requestArray.removeAtIndex(index)
                        self.tableView.reloadData()
                        return
                    }
                }
            }
        })
        
        
      
    }//end of viewDidLoad()
    
    func refreshTable(){
        for request in requestArray{
            if(requestIsOld(request.createdAt)){
                self.deleteRequestWithRequestID(request.requestID)
            }
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    //The number of rows in the section is the number of elements in the array
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Check if there are any requests, if there are, display the tableView and hide the noRequestImageView
        if(requestArray.count != 0){
            tableView.backgroundColor = UIColor.whiteColor()
            tableView.separatorColor = UIColor.lightGrayColor()
            noReuqestImageView.hidden = true
        }else{
            tableView.backgroundColor = UIColor.lightGrayColor()
            tableView.separatorColor = UIColor.clearColor()
            noReuqestImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
            view.addSubview(noReuqestImageView)
            noReuqestImageView.hidden = false
        }
        return requestArray.count
    }
    
    //Display the array of requests in the tableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("requestCell") as! RequestCell
        
        let requestUser = requestArray[indexPath.row].displayName
        let requestLocation = requestArray[indexPath.row].location
        let requestUserPhotoUrl = requestArray[indexPath.row].userPhotoURL
        let requestUserComment = requestArray[indexPath.row].comment
        
        let fullNameArr = requestUser.characters.split{$0 == " "}.map(String.init)
        let firstName: String = fullNameArr[0]
        
        let formattedString = NSMutableAttributedString()
        formattedString.bold("\(firstName)").normal(" needs a swipe at ").bold("\(requestLocation)")
        cell.textLbl.attributedText = formattedString
        cell.userCommentLbl.text = requestUserComment
        
       
        cell.timeLbl.text = calculateTimeSinceMade(requestArray[indexPath.row].createdAt)

    
        //Make user image
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage.clipsToBounds = true

        let photoUrl = NSURL(string: requestUserPhotoUrl)
        cell.userImage.image = UIImage(data: ( NSData(contentsOfURL: photoUrl!))! )
            
            
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false
        
        
        
        return cell
    }
    
    //Pop up for users to type their dining commons
    func showPopUpForRequest(){
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RequestMaker") as UIViewController
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
       
    //method to delete requests created at a specified time
    func deleteRequestWithTime(time : String!){
        // creates a reference in the databases to a set of requests ordered by the time it was created and picks the set of requests created at the time specified at the parameter of the method
        let ref = FIRDatabase.database().reference().child("Requests").queryOrderedByChild("Created_At").queryEqualToValue(time)
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children //transfer the set of requests into an array
            //iterate through the array of requests
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                //get a root reference to a request
                let ref =  FIRDatabase.database().reference().child("Requests")
                //get the key reference to specify the request
                let nodeToRemove = ref.child(rest.key)
                //remove the request from Firebase
                nodeToRemove.removeValue()
                
            }
        })
        
    }
    
    //method to delete requests based on the request ID
    func deleteRequestWithRequestID(requestID : String!){
        let ref = FIRDatabase.database().reference().child("Requests").queryOrderedByKey().queryEqualToValue(requestID)
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children //transfer the set of requests into an array
            //iterate through the array of requests
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                //get a root reference to a request
                let ref =  FIRDatabase.database().reference().child("Requests")
                //get the key reference to specify the request
                let nodeToRemove = ref.child(rest.key)
                //remove the request from Firebase
                nodeToRemove.removeValue()
                
            }
        })
        
    }
    
    
    func currentDate() -> String{
        //Calculate current time in format MM/dd/yy, HH:mm for example: 08/24/16, 10:10
        let today = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy, HH:mm"
        return formatter.stringFromDate(today)

    }
    
    //Created a post in the feed database
    func createFeedPost(requestUserUID:String, requestUserDisplayName:String, requestLocation:String, requestUserPhotoUrl:String){
        
        //Check if user is logged in. (Migth remove )
        if let user = FIRAuth.auth()?.currentUser {
            let feedPost : [String : AnyObject] = ["requestUserUID":requestUserUID,
                                                   "requestUserDisplayName":requestUserDisplayName,
                                                   "requestLocation":requestLocation,
                                                   "requestUserPhotoUrl" : requestUserPhotoUrl,
                                                   "postUserUID" : user.uid,
                                                   "postUserDisplayName": user.displayName!,
                                                   "createdAt": currentDate(),
                                                   "postUserPhotoUrl":String(user.photoURL!)]
            let databaseRef = FIRDatabase.database().reference()
            databaseRef.child("Feed Posts").childByAutoId().setValue(feedPost)
        }
    }
    
    func getAndDisplayPhoneNumber(userUID: String!, userName:String){
        
        let databaseReference =  FIRDatabase.database().reference().child("Phone Numbers").child(userUID)
        // only need to fetch once so use single event
        
        databaseReference.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.exists() {
                print ("Phone Number not found for this user id")
                return
            }
            
            if let phoneNumberValue = snapshot.value!["phoneNumber"] as? String {
                 self.displayrequestSuccessAlert(userName, requestPhoneNumber: phoneNumberValue)
            }
        })
        
    }

    
    //Share a meaa swipe table view action
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareMealSwipe = UITableViewRowAction(style: .Normal, title: "Share Meal Swipe") { action, index in
            //Check if user is logged in. (Migth remove )
            
            if let user = FIRAuth.auth()?.currentUser {
                if(self.requestArray[indexPath.row].UID != user.uid){
                    let requestUserUID = self.requestArray[indexPath.row].UID
                    let requestID = self.requestArray[indexPath.row].requestID
                    let requestDisplaName = self.requestArray[indexPath.row].displayName
                    self.getAndDisplayPhoneNumber(requestUserUID, userName: requestDisplaName)
                    let requestLocation = self.requestArray[indexPath.row].location
                    let requestPhoto = self.requestArray[indexPath.row].userPhotoURL
                    
                    self.createFeedPost(requestUserUID, requestUserDisplayName: requestDisplaName, requestLocation: requestLocation, requestUserPhotoUrl: requestPhoto)
                    
                    ///update answered variable on db to true
                    self.deleteRequestWithRequestID(requestID)
                    self.requestArray.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }else{
                    self.displayAlert("Hey there...", message: "You can't answer your own requests.... That's not how it works.")
                }
            }
        }
        shareMealSwipe.backgroundColor = UIColor(red: 60/255, green: 186/255, blue: 84/255, alpha: 1)
        
        return [shareMealSwipe]
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    //Displays UI arelt with title, message and "Okay" button
    func displayAlert(title:String, message: String){
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func calculateTimeSinceMade(requestTime:String) -> String{
        var date24 = ""
        
        if(requestTime.containsString("AM") || requestTime.containsString("PM")){
            
            //Since parse is a little bitch, we need to grab the date from the database and put it in 24hr format
            let dateFormatter1 = NSDateFormatter()
            dateFormatter1.dateFormat = "MM/dd/yy, h:mm a"
            let date = dateFormatter1.dateFromString(requestTime)
            dateFormatter1.dateFormat = "MM/dd/yy, HH:mm"
            date24 = dateFormatter1.stringFromDate(date!)
            
        }else{
            date24 = requestTime
        }
        
        //Create a time object of the current date
        let today = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy, HH:mm"
        let currentFormattedTime = formatter.stringFromDate(today)
        
        //Create a time object for the current time
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy, HH:mm"
        let dateAsString = date24
        
        //Assign both variable with nice names
        let postTime = dateFormatter.dateFromString(dateAsString)
        let currentTime = dateFormatter.dateFromString(currentFormattedTime)
        
        
        //Compare the time of both posts and the results is divided by 60, so the result is in minutes
        let timeSincePost = (currentTime!.timeIntervalSinceDate(postTime!)/60)
        
        if(timeSincePost < 60){
            return ("\(Int(timeSincePost))m")
        }else{
            return ("\(Int(timeSincePost/60))h")
        }
        
    }
    
    func calculateTimeSinceRequestWasMadeInMinutes(requestTime:String) -> Int{
        
        var date24 = ""
        
        if(requestTime.containsString("AM") || requestTime.containsString("PM")){
            
        //Since parse is a little bitch, we need to grab the date from the database and put it in 24hr format
        let dateFormatter1 = NSDateFormatter()
        dateFormatter1.dateFormat = "MM/dd/yy, h:mm a"
        let date = dateFormatter1.dateFromString(requestTime)
        dateFormatter1.dateFormat = "MM/dd/yy, HH:mm"
        date24 = dateFormatter1.stringFromDate(date!)
            
        }else{
            date24 = requestTime
        }
        
       
        
        //Create a time object of the current date
        let today = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy, HH:mm"
        let currentFormattedTime = formatter.stringFromDate(today)
        
        //Create a time object for the current time
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy, HH:mm"
        let dateAsString = date24
        
        //Assign both variable with nice names
        let postTime = dateFormatter.dateFromString(dateAsString)
        let currentTime = dateFormatter.dateFromString(currentFormattedTime)
        
        
        //Compare the time of both posts and the results is divided by 60, so the result is in minutes
        return Int((currentTime!.timeIntervalSinceDate(postTime!)/60))
        
        
        
    }
    
    func requestIsOld(requestCreatedAt:String)-> Bool{
        
        let exceeded = calculateTimeSinceRequestWasMadeInMinutes(requestCreatedAt)
            if  exceeded >= 15{
                return true
            }
        return false
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
    
    func displayrequestSuccessAlert(requestUserName: String, requestPhoneNumber: String){
        let alertView  = JSSAlertView().show( self,
        title: "Request Match!",
        text: "Help \(requestUserName) to get a swipe by texting \(requestPhoneNumber). Head over to your messages, we've started the conversation for you and be polite!",
        buttonText: "Okay!",
        color: UIColor(red:0, green: 1.0,blue:0, alpha: 1.0))
        alertView.setTextTheme(.Light)
        
    }
    
    
   
    
}


extension NSMutableAttributedString {
    func bold(text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "Arial-BoldMT", size: 14)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.appendAttributedString(boldString)
        return self
    }
    
    func normal(text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.appendAttributedString(normal)
        return self
    }
}

