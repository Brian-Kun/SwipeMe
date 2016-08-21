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

class RequestTableViewController: UITableViewController {
    
    var requestArray = [Request]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Requests"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: #selector(showPopUpForRequest))
        
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("Requests").queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            let displayName = snapshot.value!["displayName"] as! String
            let UID = snapshot.value!["UID"] as! String
            let createdAt = snapshot.value!["createdAt"] as! String
            let location = snapshot.value!["location"] as! String
            let answered = snapshot.value!["answered"] as! Bool
            
            self.requestArray.insert(Request(displayName: displayName, UID: UID, createdAt: createdAt, location: location, answered: answered), atIndex: 0)
            self.tableView.reloadData()
            
        })

    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("requestCell")
        
        let requestCellLbl = cell?.viewWithTag(1) as! UILabel
        
        let requestUser = requestArray[indexPath.row].displayName
        let requestLocation = requestArray[indexPath.row].location
        
        requestCellLbl.text = "\(requestUser) is looking for a meal swipe at \(requestLocation)"
        
        return cell!
    }
    
    
    
    func showPopUpForRequest(){
        let alert = UIAlertController(title: "Request a Swipe", message: "Where do you want to request a swipe?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (requestTextField) in }
        
        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action) in
            let requestText = alert.textFields![0] as UITextField
            self.createRequest(requestText.text!)
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func createRequest(location :String){
        
        //Check if user is logged in. (Migth remove )
        if let user = FIRAuth.auth()?.currentUser {

        let request : [String : AnyObject] = ["displayName":user.displayName!,
                                              "UID":user.uid,
                                              "createdAt":currentDate(),
                                              "location":location,
                                              "answered":false]
        
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("Requests").childByAutoId().setValue(request)
            
        }
        
    }
    
    //method to delete requests created at a specified time
    func deleteRequest(time : String!){
        // creates a reference in the databases to a set of requests ordered by the time it was created and picks the set of requ-
        //ests created at the time specified at the parameter of the method
        let ref=FIRDatabase.database().reference().child("Requests").queryOrderedByChild("Created_At").queryEqualToValue(time)
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot.childrenCount) //look at the set of requests in the snapshot data type
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
        let dateformatter = NSDateFormatter()
        
        dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        dateformatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateformatter.stringFromDate(NSDate())
    }
    
}
