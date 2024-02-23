//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

/// An enum that describes where login should occur
public enum AuthDestination {
    
    // Login should be handled within the third party application
    // using a secure embedded web browser.
    case inApp
    
    // Login should be handled inside the native uber client.
    // The library will check for the existence of each client app in the order dictated by `appPriority.
    // Omitted apps will not be launched.
    case native(
        appPriority: [UberApp] = [.rides, .eats, .driver]
    )
}

/// An enum corresponding to each Uber client application
public enum UberApp {
    
    // Uber Eats
    case eats
    
    // Uber Driver
    case driver
    
    // Uber
    case rides
}
