//
//  FeedViewController.swift
//  SwipeMe
//
//  Created by Tanaya Asnani on 8/18/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FeedTableViewController: UITableViewController {
    var feedPostArray = [FeedPost]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feed"
        let databaseRef =  FIRDatabase.database().reference()
        databaseRef.child("Feed Posts").queryOrderedByKey().observeEventType(.ChildAdded, withBlock:{
            snapshot in
            let createdAt = snapshot.value!["createdAt"] as! String
            let postUserDisplayName = snapshot.value!["postUserDisplayName"] as! String
            let postUserUID = snapshot.value!["postUserUID"] as! String
            let postUserPhotoUrl = snapshot.value!["postUserPhotoUrl"] as! String
            let requestLocation = snapshot.value!["requestLocation"] as! String
            let requestUserDisplayName = snapshot.value!["requestUserDisplayName"] as! String
            let requestUserUID = snapshot.value!["requestUserUID"] as! String
            let requestPhotoUrl = snapshot.value!["requestUserPhotoUrl"] as! String
            
            self.feedPostArray.insert(FeedPost(requestUserUID: requestUserUID, requestUserDisplayName: requestUserDisplayName,requestLocation: requestLocation,requestUserPhotoUrl: requestPhotoUrl ,postUserUID: postUserUID , postUserDisplayName: postUserDisplayName,postUserPhotoURL: postUserPhotoUrl, createdAt: createdAt), atIndex: 0)
            self.tableView.reloadData()
            
            
            
        })
        
    }
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedPostArray.count
    }
  
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedPostCell") as! FeedCell
        let requestCellLabel = cell.swipeGivenLabel
        let postUser = feedPostArray[indexPath.row].postUserDisplayName
        let requestUser = feedPostArray[indexPath.row].requestUserDisplayName
        let requestLocation = feedPostArray[indexPath.row].requestLocation
        requestCellLabel.text = "\(postUser) swiped \(requestUser) at \(requestLocation)"
        
        cell.postUserImage.layer.cornerRadius = cell.postUserImage.frame.size.width/2
        cell.postUserImage.clipsToBounds = true
        cell.postUserImage.layer.borderWidth = 2
        cell.postUserImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        
        cell.requestUserImage.layer.cornerRadius = cell.requestUserImage.frame.size.width/2
        cell.requestUserImage.clipsToBounds = true
        
    
        let postUserPhotoUrl = NSURL(string: feedPostArray[indexPath.row].postUserPhotoURL)
        cell.postUserImage.image = UIImage(data: ( NSData(contentsOfURL: postUserPhotoUrl!))! )
        
        let requestUserPhotoUrl = NSURL(string : feedPostArray[indexPath.row].requestUserPhotoUrl)
        cell.requestUserImage.image = UIImage(data : (NSData(contentsOfURL: requestUserPhotoUrl!))!)
        
        cell.timeLbl.text = calculateTimeSinceMade(feedPostArray[indexPath.row].createdAt)
        
        
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false
        return cell
        
    }
    
    func calculateTimeSinceMade(requestTime:String) -> String{
        
        //Since parse is alittle bitch, we need to grab the date from the database and put it in 24hr format
        let dateFormatter1 = NSDateFormatter()
        dateFormatter1.dateFormat = "MM/dd/yy, h:mm a"
        let date = dateFormatter1.dateFromString(requestTime)
        dateFormatter1.dateFormat = "MM/dd/yy, HH:mm"
        let date24 = dateFormatter1.stringFromDate(date!)
        
        
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


}
