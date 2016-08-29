//
//  Request.swift
//  SwipeMe
//
//  Created by Brian Ramirez on 8/20/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import Foundation
import UIKit

struct Request {
    
    let displayName: String!
    let UID : String!
    let createdAt : NSTimeInterval
    let location :String!
    let userPhotoURL: String!
    let comment: String!
    let requestID: String!//Made by firebase
    let userPhoto : UIImage!//Does not get uploaded to the db
}

