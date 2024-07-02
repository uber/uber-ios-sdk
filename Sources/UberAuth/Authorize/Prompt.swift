//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

///
/// A type defining values that specify whether the Authorization Server prompts the End-User for reauthentication and consent.
/// Current supported values are `login` and `consent`

/// See OpedID standards for more information.
/// https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest
///
public struct Prompt: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// The Authorization Server SHOULD prompt the End-User for reauthentication.
    /// If it cannot reauthenticate the End-User, it MUST return an error, typically `login_required`.
    public static let login = Prompt(rawValue: 1 << 0)
    
    /// The Authorization Server SHOULD prompt the End-User for consent before returning information to the Client. 
    /// If it cannot obtain consent, it MUST return an error, typically `consent_required`.
    public static let consent = Prompt(rawValue: 1 << 1)
    
    /// Creates a space seperated string containing the values in the option set
    var stringValue: String {
        var values: [String] = []
        if contains(.login) { values.append("login") }
        if contains(.consent) { values.append("consent") }
        return values.joined(separator: " ")
    }
}
