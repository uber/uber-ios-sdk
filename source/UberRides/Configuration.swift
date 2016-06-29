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

/**
 An enum to represent the region that the SDK should use for making requests
 
 - Default: The default region
 - China:   China, for apps that are based in China
 */
@objc public enum Region : Int {
    case Default
    case China
}

/**
 An enum to represent the possible callback URI types. Each form of authorization
 could potentially use a different URI, these are the possible types.
 
 - AuthorizationCode: Callback URI to use for Authorization Code Grant flow
 - General:           Callback URI to use for any flow
 - Implicit:          Callback URI to use for Implicit Grant flow
 - Native:            Callback URI to use for Native (SSO) flow
 */
@objc public enum CallbackURIType : Int {
    case AuthorizationCode
    case General
    case Implicit
    case Native
    
    func toString() -> String {
        switch self {
        case .AuthorizationCode:
            return "AuthorizationCode"
        case .General:
            return "General"
        case .Implicit:
            return "Implicit"
        case .Native:
            return "Native"
        }
    }
    
    static func fromString(string: String) -> CallbackURIType {
        switch string {
        case CallbackURIType.AuthorizationCode.toString():
            return .AuthorizationCode
        case CallbackURIType.Implicit.toString():
            return .Implicit
        case CallbackURIType.Native.toString():
            return .Native
        case CallbackURIType.General.toString():
            fallthrough
        default:
            return .General
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
    
    /// The .plist file to use, default is Info.plist
    public static var plistName = "Info"
    
    /// The bundle that contains the .plist file. Default is the mainBundle()
    public static var bundle = NSBundle.mainBundle()
    
    static var processPool = WKProcessPool()
    
    private static let clientIDKey = "UberClientID"
    private static let appNameKey = "UberDisplayName"
    private static let serverTokenKey = "UberServerToken"
    private static let callbackURIKey = "UberCallbackURI"
    private static let callbackURIsKey = "UberCallbackURIs"
    private static let callbackURIsTypeKey = "UberCallbackURIType"
    private static let callbackURIStringKey = "URIString"
    private static let accessTokenIdentifier = "RidesAccessTokenKey"
    
    private static var clientID : String?
    private static var callbackURIString : String?
    private static var callbackURIs = [CallbackURIType : String]()
    private static var appDisplayName: String?
    private static var serverToken: String?
    private static var defaultKeychainAccessGroup: String?
    private static var defaultAccessTokenIdentifier: String?
    private static var region : Region = .Default
    private static var isSandbox : Bool = false
    private static var useFallback: Bool = true
    
    /// The string value of the current region setting
    public static var regionString: String {
        switch region {
        case .China:
            return "china"
        case .Default:
            return "default"
        }
    }
    
    /// The current version of the SDK as a string
    public static var sdkVersion: String {
        guard let version = NSBundle(forClass: self).objectForInfoDictionaryKey("CFBundleShortVersionString") as? String else {
            return "Unknown"
        }
        return version
    }
    
    /**
     Resets all of the Configuration's values to default
     */
    public static func restoreDefaults() {
        plistName = "Info"
        bundle = NSBundle.mainBundle()
        setClientID(nil)
        setCallbackURIString(nil)
        callbackURIs = parseCallbackURIs()
        setAppDisplayName(nil)
        setServerToken(nil)
        setDefaultAccessTokenIdentifier(nil)
        setDefaultKeychainAccessGroup(nil)
        setRegion(Region.Default)
        setSandboxEnabled(false)
        setFallbackEnabled(true)
        resetProcessPool()
    }
    
    // MARK: Getters
    
    /**
     Gets the client ID of this app. Defaults to the value stored in your Application's
     plist if not set (UberClientID)
    
     - returns: The string to use for the Client ID
    */
    public static func getClientID() -> String {
        if clientID == nil {
            guard let defaultValue = getDefaultValue(clientIDKey) else {
                fatalConfigurationError("ClientID", key: clientIDKey)
            }
            clientID = defaultValue
        }

        return clientID!
    }
    
    /**
     Gets the callback URIString of this app. Defaults to the value stored in your Application's
     plist if not set (UberCallbackURI)
     
     - returns: The string to use for the Callback URI
    */
    public static func getCallbackURIString() -> String {
        return getCallbackURIString(.General)
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
    public static func getCallbackURIString(type: CallbackURIType) -> String {
        if callbackURIs[type] == nil {
            let defaultCallbacks = parseCallbackURIs()
            var fallback = defaultCallbacks[type] ?? callbackURIs[.General]
            fallback = fallback ?? defaultCallbacks[.General]
            fallback = fallback ?? getDefaultValue(callbackURIKey)
            guard let fallbackCallback = fallback else {
                fatalConfigurationError("CallbackURIStrings[\(type.toString())]", key: callbackURIsKey)
            }
            callbackURIs[type] = fallbackCallback
        }
        return callbackURIs[type]!
    }
    
    /**
     Gets the display name of this app. Defaults to the value stored in your Appication's
     plist if not set (UberClientID)
     
     - returns: The app's name
    */
    public static func getAppDisplayName() -> String {
        if appDisplayName == nil {
            guard let defaultValue = getDefaultValue(appNameKey) else {
                fatalConfigurationError("appDisplayName", key: appNameKey)
            }
            appDisplayName = defaultValue
        }
        
        return appDisplayName!
    }
    
    /**
     Gets the Server Token of this app. Defaults to the value stored in your Appication's
     plist if not set (UberServerToken)
     Optional. Used by the Request Button to get time estimates without requiring
     login
     
     - returns: The string Representing your app's server token
    */
    public static func getServerToken() -> String? {
        if serverToken == nil {
            serverToken = getDefaultValue(serverTokenKey)
        }
        
        return serverToken
    }
    
    /**
     Gets the default keychain access group to save access tokens to. Advanced setting
     for sharing access tokens between multiple of your apps. Defaults an empty string
     
     - returns: The default keychain access group to use
    */
    public static func getDefaultKeychainAccessGroup() -> String {
        guard let defaultKeychainAccessGroup = defaultKeychainAccessGroup else {
            return ""
        }
        
        return defaultKeychainAccessGroup
    }
    
    /**
     Gets the default key to use when saving access tokens to the keychain. Defaults
     to using "RidesAccessTokenKey"
     
     - returns: The default access token identifier to use
    */
    public static func getDefaultAccessTokenIdentifier() -> String {
        guard let defaultAccessTokenIdentifier = defaultAccessTokenIdentifier else {
            return accessTokenIdentifier
        }
        
        return defaultAccessTokenIdentifier
    }
    
    /**
     Gets the current region the SDK is using. Defaults to Region.Default
     
     - returns: The Region the SDK is using
     */
    public static func getRegion() -> Region {
        return region
    }
    
    /**
     Returns if sandbox is enabled or not
     
     - returns: true if Sandbox is enabled, false otherwise
     */
    public static func getSandboxEnabled() -> Bool {
        return isSandbox
    }
    
    /**
     Returns if the fallback to use Authorization Code Grant is enabled. If true,
     a failed SSO attempt will follow up with an attempt to do Authorization Code Grant
     (if requesting priveleged scopes). If false, the user will be redirected to the app store
     
     - returns: true if fallback enabled, false otherwise
     */
    public static func getFallbackEnabled() -> Bool {
        return useFallback
    }
    
    //MARK: Setters
    
    /**
     Sets a string to use as the Client ID. Overwrites the default value provided by
     the plist. Setting clientID to nil will result in using the default value
    
     - parameter clientID: The client ID String to use
    */
    public static func setClientID(clientID: String?) {
        self.clientID = clientID
    }
    
    /**
     Sets a string to use as the Callback URI String. Overwrites the default value provided by
     the plist. Setting to nil will result in using the default value.
     If you're setting a custom value, be sure your app is configured to handle deeplinks
     from this URI & you've added it to the redirect URIs on your Uber developer dashboard
     
     - parameter callbackURIString: The callback URI String to use
    */
    public static func setCallbackURIString(callbackURIString: String?) {
        setCallbackURIString(callbackURIString, type: .General)
    }
    
    /**
     Sets a string to use as the Callback URI String for the provided CallbackURIType.
     Overwrites the default value provided by the plist. Setting to nil will result 
     in using the default value.
     If you're setting a custom value, be sure your app is configured to handle deeplinks
     from this URI & you've added it to the redirect URIs on your Uber developer dashboard
     
     - parameter callbackURIString: The callback URI String to use
     - parameter type:              The Callback URI Type to use
     */
    public static func setCallbackURIString(callbackURIString: String?, type: CallbackURIType) {
        var callbackURIs = self.callbackURIs ?? [CallbackURIType : String]()
        callbackURIs[type] = callbackURIString
        self.callbackURIs = callbackURIs
    }
    
    /**
     Sets a string to use as the app display name in Uber. Overwrites the default
     value provided by the plist. Setting to nil will result in using the
     default value
     
     - parameter appDisplayName: The display name String to use
    */
    public static func setAppDisplayName(appDisplayName: String?) {
        self.appDisplayName = appDisplayName
    }
    
    /**
     Sets a string to use as the Server Token. Overwrites the default value provided by
     the plist. Setting to nil will result in using the default value
     
     - parameter serverToken: The Server Token String to use
    */
    public static func setServerToken(serverToken: String?) {
        self.serverToken = serverToken
    }
    
    /**
     Sets the default keychain access group to use. Access tokens will be saved
     here by default, unless otherwise specified at the time of login
     
     - parameter keychainAccessGroup: The client ID String to use
    */
    public static func setDefaultKeychainAccessGroup(keychainAccessGroup: String?) {
        self.defaultKeychainAccessGroup = keychainAccessGroup
    }
    
    /**
     Sets the default key to use when saving access tokens to the keychain. Setting
     to nil will result in using the default value
     
     - parameter accessTokenIdentifier: The access token identifier to use
     */
    public static func setDefaultAccessTokenIdentifier(accessTokenIdentifier: String?) {
        self.defaultAccessTokenIdentifier = accessTokenIdentifier
    }
    
    /**
     Set the region your app is registered in. Used to determine what endpoints to
     send requests to.
     
     - parameter region: The region the SDK should use
     */
    public static func setRegion(region: Region) {
        self.region = region
    }
    
    /**
     Enables / Disables Sandbox mode. When the SDK is in sandbox mode, all requests
     will go to the sandbox environment.
     
     - parameter enabled: Whether or not sandbox should be enabled
     */
    public static func setSandboxEnabled(enabled: Bool) {
        isSandbox = enabled
    }
    
    /**
     Enables / Disables the Authorization Code fallback for SSO. If enabled, the SDK
     will attempt to do Authorization Code Flow if SSO is unavailable. Otherwise, a 
     user will be directed to the appstore
     
     - parameter enabled: Whether or not fallback should be enabled
     */
    public static func setFallbackEnabled(enabled: Bool) {
        useFallback = enabled
    }
    
    // MARK: Internal
    
    static func resetProcessPool() {
        processPool = WKProcessPool()
    }
    
    // MARK: Private
    
    private static func getPlistDictionary() -> [String : AnyObject]? {
        guard let path = bundle.pathForResource(plistName, ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
                return nil
        }
        return dictionary
    }
    
    private static func getDefaultValue(key: String) -> String? {
        guard let dictionary = getPlistDictionary(),
            let defaultValue = dictionary[key] as? String else {
                return nil
        }

        return defaultValue
    }
    
    private static func parseCallbackURIs() -> [CallbackURIType : String] {
        guard let plist = getPlistDictionary(), let callbacks = plist[callbackURIsKey] as? [[String : AnyObject]] else {
            return [CallbackURIType : String]()
        }
        var callbackURIs = [CallbackURIType : String]()
        
        for callbackObject in callbacks {
            guard let callbackTypeString = callbackObject[callbackURIsTypeKey] as? String, let uriString = callbackObject[callbackURIStringKey] as? String else {
                continue
            }
            let callbackType = CallbackURIType.fromString(callbackTypeString)
            callbackURIs[callbackType] = uriString
        }
        return callbackURIs
    }
    
    @noreturn private static func fatalConfigurationError(variableName: String, key: String ) {
        fatalError("Unable to get your \(variableName). Did you forget to set it in your \(plistName).plist? (Should be under \(key) key)")
    }
    
}