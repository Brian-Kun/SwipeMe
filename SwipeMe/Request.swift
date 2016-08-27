//
//  Request.swift
//  SwipeMe
//
//  Created by Brian Ramirez on 8/20/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import Foundation

struct Request {
    
    let displayName: String!
    let UID : String!
    let createdAt : NSTimeInterval
    let location :String!
    let userPhotoURL: String!
    let comment: String!
    let requestID: String!//Made by firebase
}

