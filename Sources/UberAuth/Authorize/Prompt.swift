//
//  Prompt.swift
//  UberAuth
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
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
