//
//  ConfigurationProvider.swift
//  UberCore
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
import UIKit
import UberCore

/// @mockable
public protocol ConfigurationProviding {
    var clientID: String { get }
    var redirectURI: String { get }
    var sdkVersion: String { get }
    var serverToken: String? { get }
    static var isSandbox: Bool { get }
    
    func isInstalled(app: UberApp, defaultIfUnregistered: Bool) -> Bool
}

public struct ConfigurationProvider: ConfigurationProviding {
    
    // MARK: Public Properties
    
    public static var plistName: String = "Info"
    
    // MARK: Private Properties
    
    private let parser: PlistParser
    
    // MARK: Initializers
    
    public init() {
        let parser = PlistParser(plistName: Self.plistName)
        self.parser = parser
        
        guard let contents: [String: Any] = parser[ConfigurationKey.base] else {
            preconditionFailure("Configuration item not found: \(ConfigurationKey.base)")
        }
        
        guard let clientID = contents[ConfigurationKey.clientID] as? String else {
            preconditionFailure("Configuration item not found: \(ConfigurationKey.base)/\(ConfigurationKey.clientID)")
        }
        
        guard let redirectURI = contents[ConfigurationKey.redirectURI] as? String else {
            preconditionFailure("Configuration item not found: \(ConfigurationKey.base)/\(ConfigurationKey.clientID)")
        }
        
        self.clientID = clientID
        self.redirectURI = redirectURI
        Self.isSandbox = (contents[ConfigurationKey.sandbox] as? Bool) ?? false
        self.serverToken = contents[ConfigurationKey.serverToken] as? String
    }
    
    // MARK: ConfigurationProviding
    
    public let clientID: String
    
    public let redirectURI: String
    
    public let serverToken: String?
    
    public static var isSandbox: Bool = false
    
    /// Attempts to determine if the provided `UberApp` is installed on the current device.
    /// First checks the Info.plist to see if the required url schemes are registered. If not registered,
    /// returns `defaultIfUnregistered`.
    /// If registered, returns whether the scheme can be opened, indicating if the app is installed.
    ///
    /// - Parameters:
    ///   - app: The Uber application to check
    ///   - defaultIfUnregistered: The boolean value to return if the app's url scheme is not registered in the Info.plist
    /// - Returns: A boolean indicating if the app is installed
    public func isInstalled(app: UberApp, defaultIfUnregistered: Bool) -> Bool {
        guard let registeredSchemes: [String] = parser["LSApplicationQueriesSchemes"],
              registeredSchemes.contains(where: { $0 == app.deeplinkScheme }),
              let url = URL(string: "\(app.deeplinkScheme)://") else {
            return defaultIfUnregistered
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// The current version of the SDK as a string
    public var sdkVersion: String {
        guard let version = Bundle(for: UberButton.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return "Unknown"
        }
        return version
    }
    
    // MARK: Constants
    
    private enum ConfigurationKey {
        static let base = "Uber"
        static let clientID = "ClientID"
        static let redirectURI = "RedirectURI"
        static let serverToken = "ServerToken"
        static let sandbox = "Sandbox"
    }
}
