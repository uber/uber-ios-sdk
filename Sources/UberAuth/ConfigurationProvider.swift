//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import UIKit
import UberCore

/// @mockable
protocol ConfigurationProviding {
    var clientID: String? { get }
    var redirectURI: String? { get }
    
    func isInstalled(app: UberApp, defaultIfUnregistered: Bool) -> Bool
}

struct DefaultConfigurationProvider: ConfigurationProviding {
    
    private let parser: PlistParser
    private let contents: [String: Any]
    
    init() {
        let parser = PlistParser(plistName: "Info")
        self.parser = parser
        self.contents = parser["UberAuth"] ?? [:]
    }
    
    var clientID: String? {
        contents["ClientID"] as? String
    }
    
    var redirectURI: String? {
        contents["RedirectURI"] as? String
    }
    
    /// Attempts to determine if the provided `UberApp` is installed on the current device.
    /// First checks the Info.plist to see if the required url schemes are registered. If not registered,
    /// returns `defaultIfUnregistered`.
    /// If registered, returns whether the scheme can be opened, indicating if the app is installed.
    ///
    /// - Parameters:
    ///   - app: The Uber application to check
    ///   - defaultIfUnregistered: The boolean value to return if the app's url scheme is not registered in the Info.plist
    /// - Returns: A boolean indicating if the app is installed
    func isInstalled(app: UberApp, defaultIfUnregistered: Bool) -> Bool {
        guard let registeredSchemes: [String] = parser["LSApplicationQueriesSchemes"],
              registeredSchemes.contains(where: { $0 == app.deeplinkScheme }),
              let url = URL(string: "\(app.deeplinkScheme)://") else {
            return defaultIfUnregistered
        }
        return UIApplication.shared.canOpenURL(url)
    }
}
