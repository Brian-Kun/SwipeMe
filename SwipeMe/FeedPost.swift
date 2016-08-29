//
//  FeedPost.swift
//  SwipeMe
//
//  Created by Brian Ramirez on 8/21/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import Foundation
import UIKit

struct FeedPost {
    
    let requestUserUID:String!
    let requestUserDisplayName:String!
    let requestLocation:String!
    let requestUserPhotoUrl : String!
    let requestUserPhoto:UIImage! //Does not get uploaded to db
    let postUserUID:String
    let postUserDisplayName:String!
    let postUserPhotoURL: String!
    let postUserPhoto:UIImage! //Does not get uploaded to db
    let createdAt:NSTimeInterval!
    let postID:String!
    
    
    
}