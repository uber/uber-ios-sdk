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
@objc(UBSDKTokenManager) open class TokenManager: NSObject {

    open static let TokenManagerDidSaveTokenNotification = "TokenManagerDidSaveTokenNotification"
    open static let TokenManagerDidDeleteTokenNotification = "TokenManagerDidDeleteTokenNotification"
    
    fileprivate static let keychainWrapper = KeychainWrapper()

    //MARK: Get
    
    /**
     Gets the AccessToken for the given tokenIdentifier and accessGroup.

     - parameter tokenIdentifier: The token identifier string to use
     - parameter accessGroup:     The keychain access group to use

     - returns: An AccessToken, or nil if one wasn't found
     */
    @objc open static func fetchToken(_ tokenIdentifier: String, accessGroup: String) -> AccessToken? {
        keychainWrapper.setAccessGroup(accessGroup)
        guard let token = keychainWrapper.getObjectForKey(tokenIdentifier) as? AccessToken else {
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
    @objc open static func fetchToken(_ tokenIdentifier: String) -> AccessToken? {
        return self.fetchToken(tokenIdentifier,
            accessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    /**
     Gets the AccessToken using the default tokenIdentifier and accessGroup. 
     These values are the defined in your Configuration
     
     - returns: An AccessToken, or nil if one wasn't found
     */
    @objc open static func fetchToken() -> AccessToken? {
        return self.fetchToken(Configuration.getDefaultAccessTokenIdentifier(),
            accessGroup: Configuration.getDefaultKeychainAccessGroup())
    }

    //MARK: Save
    
    /**
     Saves the given AccessToken using the provided tokenIdentifier and acessGroup.If no values
     are supplied, it uses the defaults defined in your Configuration.
    
    Access Token is saved syncronously

     - parameter accessToken:     The AccessToken to save
     - parameter tokenIdentifier: The token identifier string to use (defaults to Configuration.getDefaultAccessTokenIdentifier())
     - parameter accessGroup:     The keychain access group to use (defaults to Configuration.getDefaultKeychainAccessGroup())

     - returns: true if the accessToken was saved successfully, false otherwise
     */
    @objc open static func saveToken(_ accessToken: AccessToken, tokenIdentifier: String, accessGroup: String) -> Bool {
        keychainWrapper.setAccessGroup(accessGroup)
        let success = keychainWrapper.setObject(accessToken, key: tokenIdentifier)
        if success {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TokenManagerDidSaveTokenNotification), object: self)
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
    @objc open static func saveToken(_ accessToken: AccessToken, tokenIdentifier: String) -> Bool {
        return self.saveToken(accessToken, tokenIdentifier: tokenIdentifier, accessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    /**
     Saves the given AccessToken. 
     Uses the default access token identifier & keychain access group defined by your
     Configuration.
     
     Access Token is saved syncronously
     
     - parameter accessToken: The AccessToken to save
     
     - returns: true if the accessToken was saved successfully, false otherwise
     */
    @objc open static func saveToken(_ accessToken: AccessToken) -> Bool {
        return self.saveToken(accessToken,  tokenIdentifier: Configuration.getDefaultAccessTokenIdentifier(), accessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    //MARK: Delete
    
    /**
     Deletes the AccessToken for the givent tokenIdentifier and accessGroup. If no values
     are supplied, it uses the defaults defined in your Configuration.

     - parameter tokenIdentifier: The token identifier string to use (defaults to Configuration.getDefaultAccessTokenIdentifier())
     - parameter accessGroup:     The keychain access group to use (defaults to Configuration.getDefaultKeychainAccessGroup())

     - returns: true if the token was deleted, false otherwise
     */
    @objc open static func deleteToken(_ tokenIdentifier: String, accessGroup: String) -> Bool {
        keychainWrapper.setAccessGroup(accessGroup)
        deleteCookies()
        let success = keychainWrapper.deleteObjectForKey(tokenIdentifier)
        if success {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TokenManagerDidDeleteTokenNotification), object: self)
        }
        return success
    }
    
    /**
     Deletes the AccessToken for the given tokenIdentifier.
     Uses the default keychain access group defined in your Configuration.
     
     - parameter tokenIdentifier: The token identifier string to use
     
     - returns: true if the token was deleted, false otherwise
     */
    @objc open static func deleteToken(_ tokenIdentifier: String) -> Bool {
        return self.deleteToken(tokenIdentifier, accessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    /**
     Deletes an AccessToken.
     Uses the default token identifier defined in your Configuration.
     Uses the default keychain access group defined in your Configuration.
     
     - returns: true if the token was deleted, false otherwise
     */
    @objc open static func deleteToken() -> Bool {
        return self.deleteToken(Configuration.getDefaultAccessTokenIdentifier(), accessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    // MARK: Private Interface
    
    fileprivate static func deleteCookies() {
        Configuration.resetProcessPool()
        var urlsToClear = [URL]()
        if let loginURL = URL(string: OAuth.regionHostString(.default)) {
            urlsToClear.append(loginURL)
        }
        if let loginURL = URL(string: OAuth.regionHostString(.china)) {
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
