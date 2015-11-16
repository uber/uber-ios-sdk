//
//  RidesClient.swift
//  Rides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//

import Foundation


public class RidesClient {
    var clientID: String?
    
    static public let sharedInstance = RidesClient()
    
    private init() {}
    
    public func setClientID(id: String) {
        clientID = id
    }
    
    public func hasClientID() -> Bool {
        return clientID != nil && clientID != "YOUR_CLIENT_ID"
    }
}
