//
//  OAuthTests.swift
//  UberRidesTests
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

import XCTest
@testable import UberCore

class OAuthTests: XCTestCase {
    var testExpectation: XCTestExpectation!
    var accessToken: AccessToken?
    var error: NSError?
    let timeout: TimeInterval = 2
    let tokenString = "accessToken1234"
    let refreshTokenString = "refresh"
    let tokenTypeString = "type"
    let expiresIn = 10030.23
    let scope = "profile history"
    
    private var redirectURI: URL!
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        redirectURI = Configuration.shared.getCallbackURI()
    }
    
    override func tearDown() {
        _ = TokenManager.deleteToken()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Test saving and object in keychain and retrieving it.
     */
    func testSaveRetrieveObjectFromKeychain() {
        guard let token = tokenFixture() else {
            XCTAssert(false)
            return
        }
        
        let keychain = KeychainWrapper()
        let key = "AccessTokenKey"
        XCTAssertTrue(keychain.setObject(token, key: key))
        
        let result = keychain.getObjectForKey(key) as! AccessToken
        XCTAssertEqual(result.tokenString, token.tokenString)
        XCTAssertEqual(result.refreshToken, token.refreshToken)
        XCTAssertEqual(result.tokenType, token.tokenType)
        XCTAssertEqual(result.grantedScopes, token.grantedScopes)
        
        XCTAssertTrue(keychain.deleteObjectForKey(key))
        
        // Make sure object was actually deleted
        XCTAssertNil(keychain.getObjectForKey(key))
    }
    
    /**
     Test saving a duplicate key with different value and verify that value is updated.
     */
    func testSaveDuplicateObjectInKeychain() {
        guard let token = tokenFixture(), let newToken = tokenFixture("newTokenString") else {
            XCTAssert(false)
            return
        }
        
        let keychain = KeychainWrapper()
        let key = "AccessTokenKey"
        XCTAssertTrue(keychain.setObject(token, key: key))
        
        XCTAssertTrue(keychain.setObject(newToken, key: key))
        
        let result = keychain.getObjectForKey(key) as! AccessToken
        XCTAssertEqual(result.tokenString, newToken.tokenString)
        XCTAssertEqual(result.refreshToken, newToken.refreshToken)
        XCTAssertEqual(result.tokenType, newToken.tokenType)
        XCTAssertEqual(result.grantedScopes, newToken.grantedScopes)
        
        XCTAssertTrue(keychain.deleteObjectForKey(key))
        
        // Make sure object was actually deleted
        XCTAssertNil(keychain.getObjectForKey(key))
    }
    
    /**
     Test that endpoint has correct query
     */
    func testImplicitGrantAuthenticator_withScopes_returnsCorrectEndpoint() {
        redirectURI = Configuration.shared.getCallbackURI(for: .implicit)
        let scopes = [UberScope.profile]
        let expectedPath = "/oauth/v2/authorize"
        let implicitGrantBehavior = ImplicitGrantAuthenticator(scopes: scopes)

        guard let queryItems = URLComponents(url: implicitGrantBehavior.authorizationURL, resolvingAgainstBaseURL: false)?.queryItems else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(implicitGrantBehavior.authorizationURL.path, expectedPath)
        XCTAssert(queryItems.contains(URLQueryItem(name: "scope", value: "profile")))
        XCTAssert(queryItems.contains(URLQueryItem(name: "client_id", value: "testClientID")))
        XCTAssert(queryItems.contains(URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString)))
    }
    
    func testInitializeAccessTokenFromString() {
        let token = AccessToken(tokenString: tokenString)
        XCTAssertEqual(token.tokenString, tokenString)
    }
    
    func testInitializeAccessTokenFromOAuthDictionary() {
        guard let token = tokenFixture() else {
            XCTFail()
            return
        }
        XCTAssertEqual(token.tokenString, tokenString)
        XCTAssertEqual(token.refreshToken, refreshTokenString)
        XCTAssertEqual(token.tokenType, tokenTypeString)
        UBSDKAssert(date: token.expirationDate!, approximatelyIn: expiresIn)
        XCTAssert(token.grantedScopes.contains(UberScope.profile))
        XCTAssert(token.grantedScopes.contains(UberScope.history))
    }
    
    func loginCompletion() -> ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) {
        return { token, error in
            self.accessToken = token
            self.error = error
            self.testExpectation.fulfill()
        }
    }
    
    // Mark: Helper
    
    func tokenFixture(_ accessToken: String = "accessToken1234") -> AccessToken?
    {
        var jsonDictionary = [String: Any]()
        jsonDictionary["access_token"] = accessToken
        jsonDictionary["refresh_token"] = refreshTokenString
        jsonDictionary["token_type"] = tokenTypeString
        jsonDictionary["expires_in"] = expiresIn
        jsonDictionary["scope"] = scope
        return AccessToken(oauthDictionary: jsonDictionary)
    }
}

extension XCTestCase {
    func UBSDKAssert(date: Date, approximatelyEqualTo otherDate: Date, _ message: String = "") {
        let allowedDifference: TimeInterval = 2
        let difference = abs(date.timeIntervalSince(otherDate))
        XCTAssert(difference < allowedDifference, message)
    }
    
    func UBSDKAssert(date: Date, approximatelyIn seconds: TimeInterval, _ message: String = "") {
        UBSDKAssert(date: date, approximatelyEqualTo: Date(timeIntervalSinceNow: seconds), message)
    }
}
