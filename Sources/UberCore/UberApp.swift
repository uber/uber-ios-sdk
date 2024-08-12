//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

/// An enum corresponding to each Uber client application
public enum UberApp: CaseIterable {
    
    // Uber Eats
    case eats
    
    // Uber Driver
    case driver
    
    // Uber
    case rides
    
    public var deeplinkScheme: String {
        switch self {
        case .eats:
            return "ubereats"
        case .driver:
            return "uberdriver"
        case .rides:
            return "uber"
        }
    }
    
    public var urlIdentifier: String {
        switch self {
        case .eats:
            return "eats"
        case .driver:
            return "drivers"
        case .rides:
            return "riders"
        }
    }
}
