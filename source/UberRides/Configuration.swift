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
    private static let callbackURIKey = "UberCallbackURI"
    private static let accessTokenIdentifier = "RidesAccessTokenKey"
    
    private static var clientID : String?
    private static var callbackURIString : String?
    private static var defaultKeychainAccessGroup: String?
    private static var defaultAccessTokenIdentifier: String?
    private static var region : Region = .Default
    private static var isSandbox : Bool = false
    
    /**
     Resets all of the Configuration's values to default
     */
    public static func restoreDefaults() {
        setClientID(nil)
        setCallbackURIString(nil)
        setDefaultAccessTokenIdentifier(nil)
        setDefaultKeychainAccessGroup(nil)
        setRegion(Region.Default)
        setSandboxEnabled(false)
        resetProcessPool()
        
        plistName = "Info"
        bundle = NSBundle.mainBundle()
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
     plist if not set (UberRedirectURL)
     
     - returns: The string to use for the Callback URI
    */
    public static func getCallbackURIString() -> String
    {
        if callbackURIString == nil {
            guard let defaultValue = getDefaultValue(callbackURIKey) else {
                fatalConfigurationError("CallbackURIString", key: callbackURIKey)
            }
            callbackURIString = defaultValue
        }
        
        return callbackURIString!
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
        self.callbackURIString = callbackURIString
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
    
    // MARK: Internal
    
    static func resetProcessPool() {
        processPool = WKProcessPool()
    }
    
    // MARK: Private
    
    private static func getDefaultValue(key: String) -> String? {
        guard let path = bundle.pathForResource(plistName, ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
            let defaultValue = dict[key] as? String else {
                return nil
        }

        return defaultValue
    }
    
    @noreturn private static func fatalConfigurationError(variableName: String, key: String ) {
        fatalError("Unable to get your \(variableName). Did you forget to set it in your \(plistName).plist? (Should be under \(key) key)")
    }
    
}