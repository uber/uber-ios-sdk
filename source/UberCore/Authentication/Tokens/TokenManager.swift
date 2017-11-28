//
//  TokenManager.swift
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

import Foundation

/// Manager class for saving and deleting AccessTokens. Allows you to manage tokens based on token identifier & keychain access group
@objc(UBSDKTokenManager) public class TokenManager: NSObject {

    @objc public static let tokenManagerDidSaveTokenNotification = "TokenManagerDidSaveTokenNotification"
    @objc public static let tokenManagerDidDeleteTokenNotification = "TokenManagerDidDeleteTokenNotification"
    
    private static let keychainWrapper = KeychainWrapper()

    //MARK: Get
    
    /**
     Gets the AccessToken for the given tokenIdentifier and accessGroup.

     - parameter identifier:      The token identifier string to use
     - parameter accessGroup:     The keychain access group to use

     - returns: An AccessToken, or nil if one wasn't found
     */
    @objc public static func fetchToken(identifier: String, accessGroup: String) -> AccessToken? {
        keychainWrapper.setAccessGroup(accessGroup)
        guard let token = keychainWrapper.getObjectForKey(identifier) as? AccessToken else {
            return nil
        }
        return token
    }
    
    /**
     Gets the AccessToken for the given tokenIdentifier.
     Uses the default value for keychain access group, as defined by your Configuration.
     
     - parameter tokenIdentifier: The token identifier string to use
     
     - returns: An AccessToken, or nil if one wasn't found
     */
    @objc public static func fetchToken(identifier: String) -> AccessToken? {
        return self.fetchToken(identifier: identifier,
            accessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }
    
    /**
     Gets the AccessToken using the default tokenIdentifier and accessGroup. 
     These values are the defined in your Configuration
     
     - returns: An AccessToken, or nil if one wasn't found
     */
    @objc public static func fetchToken() -> AccessToken? {
        return self.fetchToken(identifier: Configuration.shared.defaultAccessTokenIdentifier,
            accessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }

    //MARK: Save
    
    /**
     Saves the given AccessToken using the provided tokenIdentifier and acessGroup.If no values
     are supplied, it uses the defaults defined in your Configuration.
    
    Access Token is saved syncronously

     - parameter accessToken:     The AccessToken to save
     - parameter tokenIdentifier: The token identifier string to use (defaults to Configuration.shared.defaultAccessTokenIdentifier)
     - parameter accessGroup:     The keychain access group to use (defaults to Configuration.shared.defaultKeychainAccessGroup)

     - returns: true if the accessToken was saved successfully, false otherwise
     */
    @discardableResult @objc public static func save(accessToken: AccessToken, tokenIdentifier: String, accessGroup: String) -> Bool {
        keychainWrapper.setAccessGroup(accessGroup)
        let success = keychainWrapper.setObject(accessToken, key: tokenIdentifier)
        if success {
            NotificationCenter.default.post(name: Notification.Name(rawValue: tokenManagerDidSaveTokenNotification), object: self)
        }
        return success
    }
    
    /**
     Saves the given AccessToken using the provided tokenIdentifier. 
     Uses the default keychain access group defined by your Configuration.
     
     Access Token is saved syncronously
     
     - parameter accessToken:     The AccessToken to save
     - parameter tokenIdentifier: The token identifier string to use
     
     - returns: true if the accessToken was saved successfully, false otherwise
     */
    @discardableResult @objc public static func save(accessToken: AccessToken, tokenIdentifier: String) -> Bool {
        return self.save(accessToken: accessToken, tokenIdentifier: tokenIdentifier, accessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }
    
    /**
     Saves the given AccessToken. 
     Uses the default access token identifier & keychain access group defined by your
     Configuration.
     
     Access Token is saved syncronously
     
     - parameter accessToken: The AccessToken to save
     
     - returns: true if the accessToken was saved successfully, false otherwise
     */
    @discardableResult @objc public static func save(accessToken: AccessToken) -> Bool {
        return self.save(accessToken: accessToken,  tokenIdentifier: Configuration.shared.defaultAccessTokenIdentifier, accessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }
    
    //MARK: Delete
    
    /**
     Deletes the AccessToken for the givent tokenIdentifier and accessGroup. If no values
     are supplied, it uses the defaults defined in your Configuration.

     - parameter tokenIdentifier: The token identifier string to use (defaults to Configuration.shared.defaultAccessTokenIdentifier)
     - parameter accessGroup:     The keychain access group to use (defaults to Configuration.shared.defaultKeychainAccessGroup)

     - returns: true if the token was deleted, false otherwise
     */
    @discardableResult @objc public static func deleteToken(identifier: String, accessGroup: String) -> Bool {
        keychainWrapper.setAccessGroup(accessGroup)
        deleteCookies()
        let success = keychainWrapper.deleteObjectForKey(identifier)
        if success {
            NotificationCenter.default.post(name: Notification.Name(rawValue: tokenManagerDidDeleteTokenNotification), object: self)
        }
        return success
    }
    
    /**
     Deletes the AccessToken for the given tokenIdentifier.
     Uses the default keychain access group defined in your Configuration.
     
     - parameter tokenIdentifier: The token identifier string to use
     
     - returns: true if the token was deleted, false otherwise
     */
    @discardableResult @objc public static func deleteToken(identifier: String) -> Bool {
        return self.deleteToken(identifier: identifier, accessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }
    
    /**
     Deletes an AccessToken.
     Uses the default token identifier defined in your Configuration.
     Uses the default keychain access group defined in your Configuration.
     
     - returns: true if the token was deleted, false otherwise
     */
    @discardableResult @objc public static func deleteToken() -> Bool {
        return self.deleteToken(identifier: Configuration.shared.defaultAccessTokenIdentifier, accessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }
    
    // MARK: Private Interface
    
    private static func deleteCookies() {
        Configuration.shared.resetProcessPool()
        var urlsToClear = [URL]()
        if let loginURL = URL(string: OAuth.regionHost) {
            urlsToClear.append(loginURL)
        }
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for url in urlsToClear {
            if let cookies = sharedCookieStorage.cookies(for: url) {
                for cookie in cookies {
                    sharedCookieStorage.deleteCookie(cookie)
                }
            }
        }
    }
}
