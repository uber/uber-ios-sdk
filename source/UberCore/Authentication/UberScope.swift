//
//  UberScope.swift
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
@objc public enum UberScopeType: Int {
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
@objc(UBSDKScope) public class UberScope : NSObject {
    /// The UberScopeType of this UberScope
    @objc public let uberScopeType: UberScopeType
    /// The ScopeType of this UberScope (General / Privileged)
    @objc public let scopeType : ScopeType
    /// The String raw value of the scope
    @objc public let rawValue : String
    
    @objc public init(uberScopeType: UberScopeType) {
        self.uberScopeType = uberScopeType
        scopeType = uberScopeType.type
        rawValue = uberScopeType.toString()
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let object = object as? UberScope {
            return self.uberScopeType == object.uberScopeType
        } else {
            return false
        }
    }
    
    override public var hash: Int {
        return uberScopeType.rawValue.hashValue
    }
    
    /// Convenience variable for the AllTrips scope
    @objc public static let allTrips = UberScope(uberScopeType: .allTrips)
    
    /// Convenience variable for the History scope
    @objc public static let history = UberScope(uberScopeType: .history)
    
    /// Convenience variable for the HistoryLite scope
    @objc public static let historyLite = UberScope(uberScopeType: .historyLite)
    
    /// Convenience variable for the Places scope
    @objc public static let places = UberScope(uberScopeType: .places)
    
    /// Convenience variable for the Profile scope
    @objc public static let profile = UberScope(uberScopeType: .profile)
    
    /// Convenience variable for the Request scope
    @objc public static let request = UberScope(uberScopeType: .request)
    
    /// Convenience variable for the RequestReceipt scope
    @objc public static let requestReceipt = UberScope(uberScopeType: .requestReceipt)
    
    /// Convenience variable for the RideWidgets scope
    @objc public static let rideWidgets = UberScope(uberScopeType: .rideWidgets)
    
}

class UberScopeFactory : NSObject {
    static func uberScopeForType(_ uberScopeType: UberScopeType) -> UberScope {
        return UberScope(uberScopeType: uberScopeType)
    }
    
    static func uberScopeForString(_ rawString: String) -> UberScope? {
        guard let type = uberScopeTypeForRawValue(rawString) else {
            return nil
        }
        return uberScopeForType(type)
    }
    
    static func uberScopeTypeForRawValue(_ rawValue: String) -> UberScopeType? {
        switch rawValue.lowercased() {
        case UberScopeType.history.toString():
            return .history
        case UberScopeType.historyLite.toString():
            return .historyLite
        case UberScopeType.places.toString():
            return .places
        case UberScopeType.profile.toString():
            return .profile
        case UberScopeType.rideWidgets.toString():
            return .rideWidgets
        case UberScopeType.allTrips.toString():
            return .allTrips
        case UberScopeType.request.toString():
            return .request
        case UberScopeType.requestReceipt.toString():
            return .requestReceipt
        default:
            return nil
        }
    }
}

/**
 Extending String to allow for easy conversion from space delminated scope string
 to array of UberScopes
 */
public extension String {
    /**
     Converts a string of space delimited scopes into an array of RideScopes
     - returns: An array of UberScope representing the string
     */
    func toUberScopesArray() -> [UberScope]
    {
        var scopesArray = [UberScope]()
        for scopeString in self.components(separatedBy: " ") {
            guard let scope = UberScopeFactory.uberScopeForString(scopeString) else {
                continue
            }
            scopesArray.append(scope)
        }
        return scopesArray
    }
}

/**
 Extends SequenceType of UberScope to allow for easy conversion to a space
 delimited scope string
 */
public extension Sequence where Iterator.Element == UberScope {
    /**
     Converts an array of UberScopes into a space delimited String
     - parameter scopes: The array of UberScopes to convert
     - returns: A string representing the scopes
     */
    func toUberScopeString() -> String
    {
        var scopeStringArray = [String]()
        for scope in self {
            scopeStringArray.append(scope.rawValue)
        }
        
        return scopeStringArray.joined(separator: " ")
    }
}
