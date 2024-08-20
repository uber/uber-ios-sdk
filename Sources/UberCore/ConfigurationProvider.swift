//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
