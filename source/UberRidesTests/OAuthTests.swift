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
@testable import UberRides

class OAuthTests: XCTestCase {
    var expectation: XCTestExpectation!
    var accessToken: AccessToken?
    var error: NSError?
    let timeout: NSTimeInterval = 10
    let tokenString = "accessToken1234"
    private var redirectURI: String?
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setSandboxEnabled(true)
        redirectURI = Configuration.getCallbackURIString()
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Test for parsing successful access token retrieval.
     */
    func testParseAccessTokenFromRedirect() {
        expectation = expectationWithDescription("success access token")
        let loginView = LoginView(scopes: [.Profile])
        loginView.delegate = self
        
        let url = NSURL(string: "\(redirectURI!)#access_token=\(tokenString)")
        loginView.webView.loadRequest(NSURLRequest(URL: url!))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if error != nil {
                print("Error: \(error)")
            }
            
            XCTAssertNotNil(self.accessToken)
            XCTAssertEqual(self.accessToken!.tokenString, self.tokenString)
        })
    }
    
    /**
     Test for empty access token string (this should never happen though).
     */
    func testParseEmptyAccessTokenFromRedirect() {
        expectation = expectationWithDescription("empty access token")
        
        let loginView = LoginView(scopes: [.Profile])
        loginView.delegate = self
        
        let url = NSURL(string: "\(redirectURI!)#access_token=")
        loginView.webView.loadRequest(NSURLRequest(URL: url!))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if error != nil {
                print("Error: \(error)")
                return
            }
            
            XCTAssertNotNil(self.accessToken)
            XCTAssertEqual(self.accessToken!.tokenString, "")
        })
    }
    
    /**
     Test error mapping when redirect URI doesn't match what's expected for client ID.
     */
    func testMismatchingRedirectError() {
        expectation = expectationWithDescription("errors")
        
        let loginView = LoginView(scopes: [.Profile])
        loginView.delegate = self
        
        let url = NSURL(string: "\(redirectURI!)/errors?error=mismatching_redirect_uri")
        loginView.webView.loadRequest(NSURLRequest(URL: url!))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if error != nil {
                print("Error: \(error)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.MismatchingRedirect.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when redirect URI is invalid.
     */
    func testInvalidRedirectError() {
        expectation = expectationWithDescription("errors")
        
        let loginView = LoginView(scopes: [.Profile])
        loginView.delegate = self
        
        let url = NSURL(string: "\(redirectURI!)/errors?error=invalid_redirect_uri")
        loginView.webView.loadRequest(NSURLRequest(URL: url!))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if error != nil {
                print("Error: \(error)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.InvalidRedirect.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when client ID is invalid.
     */
    func testInvalidClientIDError() {
        expectation = expectationWithDescription("errors")
        
        let loginView = LoginView(scopes: [.Profile])
        loginView.delegate = self
        
        let url = NSURL(string: "\(redirectURI!)/errors?error=invalid_client_id")
        loginView.webView.loadRequest(NSURLRequest(URL: url!))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if error != nil {
                print("Error: \(error)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.InvalidClientID.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when scope provided is invalid.
     */
    func testInvalidScopeError() {
        expectation = expectationWithDescription("errors")
        
        let loginView = LoginView(scopes: [.Profile])
        loginView.delegate = self
        
        let url = NSURL(string: "\(redirectURI!)/errors?error=invalid_scope")
        loginView.webView.loadRequest(NSURLRequest(URL: url!))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if error != nil {
                print("Error: \(error)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.InvalidScope.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when parameters are generally invalid.
     */
    func testInvalidParametersError() {
        expectation = expectationWithDescription("errors")
        
        let loginView = LoginView(scopes: [.Profile])
        loginView.delegate = self
        
        let url = NSURL(string: "\(redirectURI!)/errors?error=invalid_parameters")
        loginView.webView.loadRequest(NSURLRequest(URL: url!))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if error != nil {
                print("Error: \(error)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.InvalidRequest.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when server error is encountered.
     */
    func testServerError() {
        expectation = expectationWithDescription("errors")
        
        let loginView = LoginView(scopes: [.Profile])
        loginView.delegate = self
        
        let url = NSURL(string: "\(redirectURI!)/errors?error=server_error")
        loginView.webView.loadRequest(NSURLRequest(URL: url!))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if error != nil {
                print("Error: \(error)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.ServerError.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    func testBuildinigWithString() {
        let tokenString = "accessTokenString"
        let token = AccessToken(tokenString: tokenString)
        XCTAssertEqual(token.tokenString, tokenString)
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
        XCTAssertEqual(result.grantedScopes!, token.grantedScopes!)
        
        XCTAssertTrue(keychain.deleteObjectForKey(key))
        
        // Make sure object was actually deleted
        XCTAssertNil(keychain.getObjectForKey(key))
    }
    
    /**
     Test saving a duplicate key with different value and verify that value is updated.
     */
    func testSaveDuplicateObjectInKeychain() {
        guard let token = tokenFixture(), newToken = tokenFixture("newTokenString") else {
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
        XCTAssertEqual(result.grantedScopes!, newToken.grantedScopes!)
        
        XCTAssertTrue(keychain.deleteObjectForKey(key))
        
        // Make sure object was actually deleted
        XCTAssertNil(keychain.getObjectForKey(key))
    }
}

// Mark: Helper

func tokenFixture(accessToken: String = "token") -> AccessToken?
{
    var jsonDictionary = [String : AnyObject]()
    jsonDictionary["access_token"] = accessToken
    jsonDictionary["refresh_token"] = "refresh"
    jsonDictionary["expires_in"] = "10030.23"
    jsonDictionary["scope"] = "profile history"
    return AccessToken(JSON: jsonDictionary)
}

extension OAuthTests: LoginViewDelegate {
    func loginView(loginView: LoginView, didSucceedWithToken accessToken: AccessToken) {
        self.accessToken = accessToken
        expectation.fulfill()
    }
    
    func loginView(loginView: LoginView, didFailWithError error: NSError) {
        self.error = error
        expectation.fulfill()
    }
}
