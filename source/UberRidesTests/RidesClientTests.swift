//
//  RidesClientTests.swift
//  UberRidesTests
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

import XCTest
@testable import UberRides

class RidesClientTests: XCTestCase {
    var client: RidesClient!
    let timeout: Double = 10
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setClientID(clientID)
        Configuration.setSandboxEnabled(true)
        client = RidesClient()
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Test to check getting the access token when using the default settings
     and the token exists
     */
    func testGetAccessTokenSuccess_defaultId_defaultGroup() {
        let tokenData = [ "access_token" : "testAccessToken" ]
        guard let token = AccessToken(JSON: tokenData) else {
            XCTAssert(false)
            return
        }

        let keychainHelper = KeychainWrapper()
        
        let tokenKey = Configuration.getDefaultAccessTokenIdentifier()
        let tokenGroup = Configuration.getDefaultKeychainAccessGroup()
        
        keychainHelper.setAccessGroup(tokenGroup)
        keychainHelper.setObject(token, key: tokenKey)
        defer {
            keychainHelper.deleteObjectForKey(tokenKey)
        }
        
        let ridesClient = RidesClient()
        guard let accessToken = ridesClient.getAccessToken() else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(accessToken.tokenString, token.tokenString)
    }
    
    /**
     Test to check getting the access token when using the default settings
     and the token doesn't exist
     */
    func testGetAccessTokenFail_defaultId_defaultGroup() {
        let ridesClient = RidesClient()
        let accessToken = ridesClient.getAccessToken()
        XCTAssertNil(accessToken)
    }
    
    /**
     Test to check getting the access token when using a custom ID and default group
     and the token exists
     */
    func testGetAccessTokenSuccess_customId_defaultGroup() {
        let tokenData = [ "access_token" : "testAccessToken" ]
        guard let token = AccessToken(JSON: tokenData) else {
            XCTAssert(false)
            return
        }
        let keychainHelper = KeychainWrapper()
        
        let tokenKey = "newTokenKey"
        let tokenGroup = Configuration.getDefaultKeychainAccessGroup()
        
        keychainHelper.setAccessGroup(tokenGroup)
        keychainHelper.setObject(token, key: tokenKey)
        defer {
            keychainHelper.deleteObjectForKey(tokenKey)
        }
        
        let ridesClient = RidesClient(accessTokenIdentifier:tokenKey)
        guard let accessToken = ridesClient.getAccessToken() else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(accessToken.tokenString, token.tokenString)
    }
    
    /**
     Test to check getting the access token when using the default ID and cusom group
     and the token exists
     */
    func testGetAccessTokenSuccess_defaultId_customGroup() {
        let tokenData = [ "access_token" : "testAccessToken" ]
        guard let token = AccessToken(JSON: tokenData) else {
            XCTAssert(false)
            return
        }
        let keychainHelper = KeychainWrapper()
        
        let tokenKey = Configuration.getDefaultAccessTokenIdentifier()
        let tokenGroup =  "newTokenGroup"
        
        keychainHelper.setAccessGroup(tokenGroup)
        keychainHelper.setObject(token, key: tokenKey)
        defer {
            keychainHelper.deleteObjectForKey(tokenKey)
        }
        
        let ridesClient = RidesClient(accessTokenIdentifier: tokenKey, keychainAccessGroup:tokenGroup)
        guard let accessToken = ridesClient.getAccessToken() else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(accessToken.tokenString, token.tokenString)
    }
    
    /**
     Test to check getting the access token when using custom settings
     and the token exists
     */
    func testGetAccessTokenSuccess_customId_customGroup() {
        let tokenData = [ "access_token" : "testAccessToken" ]
        guard let token = AccessToken(JSON: tokenData) else {
            XCTAssert(false)
            return
        }
        let keychainHelper = KeychainWrapper()
        
        let tokenKey = "newTokenID"
        let tokenGroup =  "newTokenGroup"
        
        keychainHelper.setAccessGroup(tokenGroup)
        keychainHelper.setObject(token, key: tokenKey)
        defer {
            keychainHelper.deleteObjectForKey(tokenKey)
        }
        
        let ridesClient = RidesClient(accessTokenIdentifier: tokenKey, keychainAccessGroup:tokenGroup)
        guard let accessToken = ridesClient.getAccessToken() else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(accessToken.tokenString, token.tokenString)
    }
    
    /**
     Test to check getting the access token when using custom settings
     and the token doesn't exist
     */
    func testGetAccessTokenFailure_customId_customGroup() {
        let tokenData = [ "access_token" : "testAccessToken" ]
        guard let token = AccessToken(JSON: tokenData) else {
            XCTAssert(false)
            return
        }
        let keychainHelper = KeychainWrapper()
        
        let tokenKey = "newTokenID"
        let tokenGroup =  "newTokenGroup"
        
        keychainHelper.setAccessGroup(tokenGroup)
        keychainHelper.setObject(token, key: tokenKey)
        defer {
            keychainHelper.deleteObjectForKey(tokenKey)
        }
        
        let ridesClient = RidesClient()
        let accessToken = ridesClient.getAccessToken()
        XCTAssertNil(accessToken)
    }
    
    /**
     Test to check getting the access token fails when using a matching ID but different
     group
     */
    func testGetAccessTokenFailure_groupMismatch() {
        let tokenData = [ "access_token" : "testAccessToken" ]
        guard let token = AccessToken(JSON: tokenData) else {
            XCTAssert(false)
            return
        }
        let keychainHelper = KeychainWrapper()
        
        let tokenKey = "newTokenID"
        let tokenGroup =  "newTokenGroup"
        
        keychainHelper.setAccessGroup(tokenGroup)
        keychainHelper.setObject(token, key: tokenKey)
        defer {
            keychainHelper.deleteObjectForKey(tokenKey)
        }
        
        let ridesClient = RidesClient(accessTokenIdentifier: tokenKey)
        let accessToken = ridesClient.getAccessToken()
        XCTAssertNil(accessToken)
    }
}
