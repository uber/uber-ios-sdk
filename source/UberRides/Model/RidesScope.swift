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
    case general, privileged
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
    case allTrips
    case history
    case historyLite
    case places
    case profile
    case request
    case requestReceipt
    case rideWidgets
    
    
    var type: ScopeType {
        switch(self) {
        case .history: fallthrough
        case .historyLite: fallthrough
        case .places: fallthrough
        case .profile: fallthrough
        case .rideWidgets:
            return .general
        case .allTrips: fallthrough
        case .request: fallthrough
        case .requestReceipt:
            return .privileged
        }
    }
    
    func toString() -> String {
        switch self {
        case .allTrips:
            return "all_trips"
        case .history:
            return "history"
        case .historyLite:
            return "history_lite"
        case .places:
            return "places"
        case .profile:
            return "profile"
        case .request:
            return "request"
        case .requestReceipt:
            return "request_receipt"
        case .rideWidgets:
            return "ride_widgets"
        }
    }
}

/**
 *  Object representing an access scope to the Uber API
 */
@objc(UBSDKRidesScope) open class RidesScope : NSObject {
    /// The RidesScopeType of this RidesScope
    open let ridesScopeType: RidesScopeType
    /// The ScopeType of this RidesScope (General / Privileged)
    open let scopeType : ScopeType
    /// The String raw value of the scope
    open let rawValue : String
    
    public init(ridesScopeType: RidesScopeType) {
        self.ridesScopeType = ridesScopeType
        scopeType = ridesScopeType.type
        rawValue = ridesScopeType.toString()
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        if let object = object as? RidesScope {
            return self.ridesScopeType == object.ridesScopeType
        } else {
            return false
        }
    }
    
    override open var hash: Int {
        return ridesScopeType.rawValue.hashValue
    }
    
    /// Convenience variable for the AllTrips scope
    open static let AllTrips = RidesScope(ridesScopeType: .allTrips)
    
    /// Convenience variable for the History scope
    open static let History = RidesScope(ridesScopeType: .history)
    
    /// Convenience variable for the HistoryLite scope
    open static let HistoryLite = RidesScope(ridesScopeType: .historyLite)
    
    /// Convenience variable for the Places scope
    open static let Places = RidesScope(ridesScopeType: .places)
    
    /// Convenience variable for the Profile scope
    open static let Profile = RidesScope(ridesScopeType: .profile)
    
    /// Convenience variable for the Request scope
    open static let Request = RidesScope(ridesScopeType: .request)
    
    /// Convenience variable for the RequestReceipt scope
    open static let RequestReceipt = RidesScope(ridesScopeType: .requestReceipt)
    
    /// Convenience variable for the RideWidgets scope
    open static let RideWidgets = RidesScope(ridesScopeType: .rideWidgets)
    
}

class RidesScopeFactory : NSObject {
    static func ridesScopeForType(_ ridesScopeType: RidesScopeType) -> RidesScope {
        return RidesScope(ridesScopeType: ridesScopeType)
    }
    
    static func ridesScopeForString(_ rawString: String) -> RidesScope? {
        guard let type = ridesScopeTypeForRawValue(rawString) else {
            return nil
        }
        return ridesScopeForType(type)
    }
    
    static func ridesScopeTypeForRawValue(_ rawValue: String) -> RidesScopeType? {
        switch rawValue.lowercased() {
        case RidesScopeType.history.toString():
            return .history
        case RidesScopeType.historyLite.toString():
            return .historyLite
        case RidesScopeType.places.toString():
            return .places
        case RidesScopeType.profile.toString():
            return .profile
        case RidesScopeType.rideWidgets.toString():
            return .rideWidgets
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
        for scopeString in self.components(separatedBy: " ") {
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
extension Sequence where Iterator.Element == RidesScope {
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
        
        return scopeStringArray.joined(separator: " ")
    }
}
