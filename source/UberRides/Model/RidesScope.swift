//
//  RidesScope.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/**
 Category of scope that describes its level of access.
 
 - General:    scopes that can be used without review.
 - Privileged: scopes that require approval before opened to your users in production.
 */
@objc public enum ScopeType : Int {
    case General, Privileged
}

/**
 Scopes control the various API endpoints your application can access.

 - AllTrips:       Get details of the trip the user is currently taking.
 - History:        Pull trip data of a user's historical pickups and drop-offs.
 - HistoryLite:    Same as History without city information.
 - Places:         Save and retrieve user's favorite places.
 - Profile:        Access basic profile information on a user's Uber account.
 - Request:        Make requests for Uber rides on behalf of users.
 - RideReceipt:    Get receipt details for requests made by application.
 - RideWidgets:    The scope for using the Ride Request Widget.
 */
@objc public enum RidesScopeType: Int {
    case AllTrips
    case History
    case HistoryLite
    case Places
    case Profile
    case Request
    case RequestReceipt
    case RideWidgets
    
    
    var type: ScopeType {
        switch(self) {
        case .History: fallthrough
        case .HistoryLite: fallthrough
        case .Places: fallthrough
        case .Profile: fallthrough
        case .RideWidgets:
            return .General
        case .AllTrips: fallthrough
        case .Request: fallthrough
        case .RequestReceipt:
            return .Privileged
        }
    }
    
    func toString() -> String {
        switch self {
        case .AllTrips:
            return "all_trips"
        case .History:
            return "history"
        case .HistoryLite:
            return "history_lite"
        case .Places:
            return "places"
        case .Profile:
            return "profile"
        case .Request:
            return "request"
        case .RequestReceipt:
            return "request_receipt"
        case .RideWidgets:
            return "ride_widgets"
        }
    }
}

/**
 *  Object representing an access scope to the Uber API
 */
@objc(UBSDKRidesScope) public class RidesScope : NSObject {
    /// The RidesScopeType of this RidesScope
    public let ridesScopeType: RidesScopeType
    /// The ScopeType of this RidesScope (General / Privileged)
    public let scopeType : ScopeType
    /// The String raw value of the scope
    public let rawValue : String
    
    public init(ridesScopeType: RidesScopeType) {
        self.ridesScopeType = ridesScopeType
        scopeType = ridesScopeType.type
        rawValue = ridesScopeType.toString()
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? RidesScope {
            return self.ridesScopeType == object.ridesScopeType
        } else {
            return false
        }
    }
    
    override public var hash: Int {
        return ridesScopeType.rawValue.hashValue
    }
    
    /// Convenience variable for the AllTrips scope
    public static let AllTrips = RidesScope(ridesScopeType: .AllTrips)
    
    /// Convenience variable for the History scope
    public static let History = RidesScope(ridesScopeType: .History)
    
    /// Convenience variable for the HistoryLite scope
    public static let HistoryLite = RidesScope(ridesScopeType: .HistoryLite)
    
    /// Convenience variable for the Places scope
    public static let Places = RidesScope(ridesScopeType: .Places)
    
    /// Convenience variable for the Profile scope
    public static let Profile = RidesScope(ridesScopeType: .Profile)
    
    /// Convenience variable for the Request scope
    public static let Request = RidesScope(ridesScopeType: .Request)
    
    /// Convenience variable for the RequestReceipt scope
    public static let RequestReceipt = RidesScope(ridesScopeType: .RequestReceipt)
    
    /// Convenience variable for the RideWidgets scope
    public static let RideWidgets = RidesScope(ridesScopeType: .RideWidgets)
    
}

class RidesScopeFactory : NSObject {
    static func ridesScopeForType(ridesScopeType: RidesScopeType) -> RidesScope {
        return RidesScope(ridesScopeType: ridesScopeType)
    }
    
    static func ridesScopeForString(rawString: String) -> RidesScope? {
        guard let type = ridesScopeTypeForRawValue(rawString) else {
            return nil
        }
        return ridesScopeForType(type)
    }
    
    static func ridesScopeTypeForRawValue(rawValue: String) -> RidesScopeType? {
        switch rawValue.lowercaseString {
        case RidesScopeType.History.toString():
            return .History
        case RidesScopeType.HistoryLite.toString():
            return .HistoryLite
        case RidesScopeType.Places.toString():
            return .Places
        case RidesScopeType.Profile.toString():
            return .Profile
        case RidesScopeType.RideWidgets.toString():
            return .RideWidgets
        case RidesScopeType.AllTrips.toString():
            return .AllTrips
        case RidesScopeType.Request.toString():
            return .Request
        case RidesScopeType.RequestReceipt.toString():
            return .RequestReceipt
        default:
            return nil
        }
    }
}

/**
 Extending String to allow for easy conversion from space delminated scope string
 to array of RidesScopes
 */
extension String {
    /**
     Converts a string of space delimited scopes into an array of RideScopes
     - returns: An array of RidesScope representing the string
     */
    func toRidesScopesArray() -> [RidesScope]
    {
        var scopesArray = [RidesScope]()
        for scopeString in self.componentsSeparatedByString(" ") {
            guard let scope = RidesScopeFactory.ridesScopeForString(scopeString) else {
                continue
            }
            scopesArray.append(scope)
        }
        return scopesArray
    }
}

/**
 Extends SequenceType of RidesScope to allow for easy conversion to a space 
 delimited scope string
 */
extension SequenceType where Generator.Element == RidesScope {
    /**
     Converts an array of RidesScopes into a space delimited String
     - parameter scopes: The array of RidesScopes to convert
     - returns: A string representing the scopes
     */
    func toRidesScopeString() -> String
    {
        var scopeStringArray = [String]()
        for scope in self {
            scopeStringArray.append(scope.rawValue)
        }
        
        return scopeStringArray.joinWithSeparator(" ")
    }
}
