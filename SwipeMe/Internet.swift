//
//  Internet.swift
//  SwipeMe
//
//  Created by Brian Ramirez on 8/26/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import Foundation
import ReachabilitySwift

class Internet {
    
    static func isConnected() -> Bool{
        let reachability: Reachability
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            return false
        }
        
        return true

    }
    
}