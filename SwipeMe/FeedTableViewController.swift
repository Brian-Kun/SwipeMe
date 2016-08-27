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
import JSSAlertView

class FeedTableViewController: UITableViewController {
    
    var feedPostArray = [FeedPost]()
    
    let noFeedActivityImageView = UIImageView(image: UIImage(named: "noFeedActivity")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!Reachability.isConnectedToNetwork()){
            displayNoInternetAlert()
        }
        
        tableView.dataSource = self
        
        self.refreshControl?.addTarget(self, action: #selector(refreshTable), forControlEvents: UIControlEvents.ValueChanged)
        
        
        //Hide the tableview and display the noRequestImageView. We don't wanna show an empty tableview...
        tableView.backgroundColor = UIColor.lightGrayColor()
        tableView.separatorColor = UIColor.clearColor()
        noFeedActivityImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        view.addSubview(noFeedActivityImageView)
        noFeedActivityImageView.hidden = false
        
        self.title = "Feed"
        let databaseRef =  FIRDatabase.database().reference()
        databaseRef.child("Feed Posts").queryOrderedByKey().observeEventType(.ChildAdded, withBlock:{
            snapshot in
            let createdAt = snapshot.value!["createdAt"] as! NSTimeInterval
            let postUserDisplayName = snapshot.value!["postUserDisplayName"] as! String
            let postUserUID = snapshot.value!["postUserUID"] as! String
            let postUserPhotoUrl = snapshot.value!["postUserPhotoUrl"] as! String
            let requestLocation = snapshot.value!["requestLocation"] as! String
            let requestUserDisplayName = snapshot.value!["requestUserDisplayName"] as! String
            let requestUserUID = snapshot.value!["requestUserUID"] as! String
            let requestPhotoUrl = snapshot.value!["requestUserPhotoUrl"] as! String
            let postID = snapshot.key
            
            self.feedPostArray.insert(FeedPost(requestUserUID: requestUserUID, requestUserDisplayName: requestUserDisplayName,requestLocation: requestLocation,requestUserPhotoUrl: requestPhotoUrl ,postUserUID: postUserUID , postUserDisplayName: postUserDisplayName,postUserPhotoURL: postUserPhotoUrl, createdAt: createdAt, postID: postID), atIndex: 0)
            self.tableView.reloadData()
            
            
            
        })
        
    }
    
    func refreshTable(){
        for post in feedPostArray{
            if(feedPostIsOld(post.createdAt)){
                self.deletePostWithID(post.postID)
            }
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //Check if there are any requests, if there are, display the tableView and hide the noRequestImageView
        if(feedPostArray.count != 0){
            tableView.backgroundColor = UIColor.whiteColor()
            tableView.separatorColor = UIColor.lightGrayColor()
            noFeedActivityImageView.hidden = true
        }else{
            //Hide the tableview and display the noRequestImageView. We don't wanna show an empty tableview...
            tableView.backgroundColor = UIColor.lightGrayColor()
            tableView.separatorColor = UIColor.clearColor()
            noFeedActivityImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
            view.addSubview(noFeedActivityImageView)
            noFeedActivityImageView.hidden = false
        }
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
    
    //method to delete requests based on the request ID
    func deletePostWithID(postId : String!){
        let ref = FIRDatabase.database().reference().child("Feed Posts").queryOrderedByKey().queryEqualToValue(postId)
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children //transfer the set of requests into an array
            //iterate through the array of requests
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                //get a root reference to a request
                let ref =  FIRDatabase.database().reference().child("Feed Posts")
                //get the key reference to specify the request
                let nodeToRemove = ref.child(rest.key)
                //remove the request from Firebase
                nodeToRemove.removeValue()
                
            }
        })
        
    }
    
    func timeSincePostWasMade(postTime:NSTimeInterval) -> Int{
        
        let postTime = NSDate(timeIntervalSince1970: postTime)
        
        let timeNow = NSDate().timeIntervalSince1970
        let currentTime = NSDate(timeIntervalSince1970: timeNow)
        
        
        //Compare the time of both posts and the results is divided by 60, so the result is in minutes
        return Int((currentTime.timeIntervalSinceDate(postTime)/60))
        
    }
    
    func feedPostIsOld(requestCreatedAt:NSTimeInterval)-> Bool{
        
        let exceeded = timeSincePostWasMade(requestCreatedAt)
        //Feed posts are old after 24hrs
        if  exceeded >= 1440{
            return true
        }
        return false
    }
    
    func calculateTimeSinceMade(requestTime:NSTimeInterval) -> String{
        
        let postTime = NSDate(timeIntervalSince1970: requestTime)
        
        let timeNow = NSDate().timeIntervalSince1970
        let currentTime = NSDate(timeIntervalSince1970: timeNow)
        
        //Compare the time of both posts and the results is divided by 60, so the result is in minutes
        let timeSincePost = (currentTime.timeIntervalSinceDate(postTime)/60)
        
        if(timeSincePost < 60){
            return ("\(Int(timeSincePost))m")
        }else{
            return ("\(Int(timeSincePost/60))h")
        }
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
