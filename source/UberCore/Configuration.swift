//
//  Configuration.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
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
import WebKit

private let clientIDKey = "UberClientID"
private let appNameKey = "UberDisplayName"
private let serverTokenKey = "UberServerToken"
private let callbackURIKey = "UberCallbackURI"
private let callbackURIsKey = "UberCallbackURIs"
private let callbackURIsTypeKey = "UberCallbackURIType"
private let callbackURIStringKey = "URIString"

/**
 An enum to represent the possible callback URI types. Each form of authorization
 could potentially use a different URI, these are the possible types.
 
 - AuthorizationCode: Callback URI to use for Authorization Code Grant flow
 - General:           Callback URI to use for any flow
 - Implicit:          Callback URI to use for Implicit Grant flow
 - Native:            Callback URI to use for Native (SSO) flow
 */
@objc(UBSDKCallbackURIType) public enum CallbackURIType : Int {
    case authorizationCode
    case general
    case implicit
    case native
    
    func toString() -> String {
        switch self {
        case .authorizationCode:
            return "AuthorizationCode"
        case .general:
            return "General"
        case .implicit:
            return "Implicit"
        case .native:
            return "Native"
        }
    }
    
    static func fromString(_ string: String) -> CallbackURIType {
        switch string {
        case CallbackURIType.authorizationCode.toString():
            return .authorizationCode
        case CallbackURIType.implicit.toString():
            return .implicit
        case CallbackURIType.native.toString():
            return .native
        case CallbackURIType.general.toString():
            fallthrough
        default:
            return .general
        }
    }
}

/**
 Class responsible for handling all of the SDK Configuration options. Provides
 default values for Application-wide configuration properties. All properties are 
 configurable via the respective setter method
*/
@objc(UBSDKConfiguration) public class Configuration : NSObject {
    // MARK : Variables
    @objc public static var shared: Configuration = Configuration()
    
    /// The .plist file to use, default is Info.plist
    @objc public static var plistName = "Info"
    
    /// The bundle that contains the .plist file. Default is the mainBundle()
    @objc public static var bundle = Bundle.main
    
    @objc public var processPool = WKProcessPool()

    /**
     Gets the client ID of this app. Defaults to the value stored in your Application's
     plist if not set (UberClientID)

     - returns: The string to use for the Client ID
     */
    @objc public var clientID: String

    private var callbackURIs = [CallbackURIType: URL]()

    /**
     Gets the display name of this app. Defaults to the value stored in your Appication's
     plist if not set (UberClientID)

     - returns: The app's name
     */
    @objc public var appDisplayName: String

    /**
     Gets the Server Token of this app. Defaults to the value stored in your Appication's
     plist if not set (UberServerToken)
     Optional. Used by the Request Button to get time estimates without requiring
     login

     - returns: The string Representing your app's server token
     */
    @objc public var serverToken: String?

    /**
     Gets the default keychain access group to save access tokens to. Advanced setting
     for sharing access tokens between multiple of your apps. Defaults an empty string

     - returns: The default keychain access group to use
     */
    @objc public var defaultKeychainAccessGroup: String = ""

    /**
     Gets the default key to use when saving access tokens to the keychain. Defaults
     to using "RidesAccessTokenKey"

     - returns: The default access token identifier to use
     */
    @objc public var defaultAccessTokenIdentifier: String = "RidesAccessTokenKey"

    /**
     Returns if sandbox is enabled or not

     - returns: true if Sandbox is enabled, false otherwise
     */
    @objc public var isSandbox: Bool = false

    /**
     Returns if the fallback to use Authorization Code Grant is enabled. If true,
     a failed SSO attempt will follow up with an attempt to do Authorization Code Grant
     (if requesting priveleged scopes). If false, the user will be redirected to the app store

     - returns: true if fallback enabled, false otherwise
     */
    @objc public var useFallback: Bool = false

    public override init() {
        self.clientID = ""
        self.appDisplayName = ""

        super.init()

        if let defaultValue = getDefaultValue(clientIDKey) {
            self.clientID = defaultValue
        } else {
            fatalConfigurationError("ClientID", key: clientIDKey)
        }
        if let defaultValue = getDefaultValue(appNameKey) {
            self.appDisplayName = defaultValue
        } else {
            fatalConfigurationError("appDisplayName", key: appNameKey)
        }
        serverToken = getDefaultValue(serverTokenKey)
    }
    
    /// The current version of the SDK as a string
    @objc public var sdkVersion: String {
        guard let version = Bundle(for: Configuration.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return "Unknown"
        }
        return version
    }
    
    /**
     Resets all of the Configuration's values to default
     */
    @objc public static func restoreDefaults() {
        shared = Configuration()
    }
    
    // MARK: Getters
    
    /**
     Gets the callback URI of this app. Defaults to the value stored in your Application's
     plist if not set (UberCallbackURI)
     
     - returns: The string to use for the Callback URI
    */
    @objc public func getCallbackURI() -> URL {
        return getCallbackURI(for: .general)
    }

    /**
     Gets the callback URIString of this app. Defaults to the value stored in your Application's
     plist if not set (UberCallbackURI)

     - returns: The string to use for the Callback URI
     */
    @objc public func getCallbackURIString() -> String {
        return getCallbackURI().absoluteString
    }
    
    /**
     Gets the callback URI for the given CallbackURIType. Defaults to the value
     stored in your Applications' plist (under the UberCallbackURIs key). If the requested
     type is not defined in your plist, it will attempt to use the .General type. If the 
     .General type is not defined, it will attempt to use the value stored under the UberCallbackURI key.
     Throws a fatal error if no value can be determined
     
     - parameter type: The CallbackURIType to get a callback string for
     
     - returns: The callbackURI for the the requested type
     */
    @objc public func getCallbackURI(for type: CallbackURIType) -> URL {
        if callbackURIs[type] == nil {
            let defaultCallbacks = parseCallbackURIs()
            var fallback = defaultCallbacks[type] ?? callbackURIs[.general]
            fallback = fallback ?? defaultCallbacks[.general]
            if let defaultValue = getDefaultValue(callbackURIKey) {
                fallback = fallback ?? URL(string: defaultValue)
            }
            guard let fallbackCallback = fallback else {
                fatalConfigurationError("CallbackURI[\(type.toString())]", key: callbackURIsKey)
            }
            callbackURIs[type] = fallbackCallback
        }
        return callbackURIs[type]!
    }

    /**
     Gets the callback URIString for the given CallbackURIType. Defaults to the value
     stored in your Applications' plist (under the UberCallbackURIs key). If the requested
     type is not defined in your plist, it will attempt to use the .General type. If the
     .General type is not defined, it will attempt to use the value stored under the UberCallbackURI key.
     Throws a fatal error if no value can be determined

     - parameter type: The CallbackURIType to get a callback string for

     - returns: The callbackURIString for the the requested type
     */
    @objc public func getCallbackURIString(for type: CallbackURIType) -> String {
        return getCallbackURI(for: type).absoluteString
    }
    
    //MARK: Setters
    
    /**
     Sets a string to use as the Callback URI String. Overwrites the default value provided by
     the plist. Setting to nil will result in using the default value.
     If you're setting a custom value, be sure your app is configured to handle deeplinks
     from this URI & you've added it to the redirect URIs on your Uber developer dashboard
     
     - parameter callbackURI: The callback URI String to use
    */
    @objc public func setCallbackURI(_ callbackURI: URL?) {
        setCallbackURI(callbackURI, type: .general)
    }
    
    /**
     Sets a string to use as the Callback URI String for the provided CallbackURIType.
     Overwrites the default value provided by the plist. Setting to nil will result 
     in using the default value.
     If you're setting a custom value, be sure your app is configured to handle deeplinks
     from this URI & you've added it to the redirect URIs on your Uber developer dashboard
     
     - parameter callbackURI: The callback URI String to use
     - parameter type:              The Callback URI Type to use
     */
    @objc public func setCallbackURI(_ callbackURI: URL?, type: CallbackURIType) {
        var callbackURIs = self.callbackURIs
        callbackURIs[type] = callbackURI
        self.callbackURIs = callbackURIs
    }

    public func resetProcessPool() {
        DispatchQueue.main.async {
            self.processPool = WKProcessPool()
        }
    }
    
    // MARK: Private
    
    private func parseCallbackURIs() -> [CallbackURIType : URL] {
        guard let plist = getPlistDictionary(), let callbacks = plist[callbackURIsKey] as? [[String: AnyObject]] else {
            return [CallbackURIType: URL]()
        }
        var callbackURIs = [CallbackURIType : URL]()
        
        for callbackObject in callbacks {
            guard let callbackTypeString = callbackObject[callbackURIsTypeKey] as? String,
                let uriString = callbackObject[callbackURIStringKey] as? String,
                let uri = URL(string: uriString) else {
                continue
            }
            let callbackType = CallbackURIType.fromString(callbackTypeString)
            callbackURIs[callbackType] = uri
        }
        return callbackURIs
    }

    private func fatalConfigurationError(_ variableName: String, key: String ) -> Never  {
        fatalError("Unable to get your \(variableName). Did you forget to set it in your \(Configuration.plistName).plist? (Should be under \(key) key)")
    }

    private func getPlistDictionary() -> [String : AnyObject]? {
        guard let path = Configuration.bundle.path(forResource: Configuration.plistName, ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
                return nil
        }
        return dictionary
    }

    private func getDefaultValue(_ key: String) -> String? {
        guard let dictionary = getPlistDictionary(),
            let defaultValue = dictionary[key] as? String else {
                return nil
        }

        return defaultValue
    }
}
