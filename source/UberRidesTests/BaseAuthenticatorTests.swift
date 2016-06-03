//
//  BaseAuthenticatorTests.swift
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

import XCTest
@testable import UberRides

class BaseAuthenticatorTests: XCTestCase {
    private var expectation: XCTestExpectation!
    private var accessToken: AccessToken?
    private var error: NSError?
    private let timeout: NSTimeInterval = 2
    private let tokenString = "accessToken1234"
    private var redirectURI: String = ""
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setSandboxEnabled(true)
        redirectURI = Configuration.getCallbackURIString(.General)
    }
    
    override func tearDown() {
        TokenManager.deleteToken()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testBaseAuthenticator_usesGeneralCallback() {
        let baseAuthenticator = BaseAuthenticator(scopes: [])
        XCTAssertEqual(baseAuthenticator.callbackURIType, CallbackURIType.General)
    }
    
    func testBaseAuthenticator_correctlySavesScopes() {
        let scopes = [RidesScope.Profile, RidesScope.AllTrips]
        let baseAuthenticator = BaseAuthenticator(scopes: scopes)
        XCTAssertEqual(scopes, baseAuthenticator.scopes);
    }
    
    func testBaseAuthenticator_handleRedirectFalse_whenURLNil() {
        let emptyRequest = NSURLRequest()
        let baseAuthenticator = BaseAuthenticator(scopes: [])
        XCTAssertFalse(baseAuthenticator.handleRedirectRequest(emptyRequest))
    }
    
    func testBaseAuthenticator_handleRedirectFalse_whenURLNotRedirect() {
        let redirectURLString = "testURI://redirect"
        let notRedirectURLString = "testURI://notRedirect"
        Configuration.setCallbackURIString(redirectURLString, type: .General)
        guard let notRedirectURL = NSURL(string: notRedirectURLString) else {
            XCTFail()
            return
        }
        let handleRequest = NSURLRequest(URL: notRedirectURL)
        let baseAuthenticator = BaseAuthenticator(scopes: [])
        XCTAssertFalse(baseAuthenticator.handleRedirectRequest(handleRequest))
    }
    
    func testBaseAuthenticator_handleRedirectTrue_whenValidRedirect() {
        let expectation = expectationWithDescription("Login completion called")
        
        let loginCompletionBlock: ((accessToken: AccessToken?, error: NSError?) -> Void) = { (_,_) in
            expectation.fulfill()
        }
        
        let redirectURLString = "testURI://redirect?error=server_error"
        Configuration.setCallbackURIString(redirectURLString, type: .General)
        guard let redirectURL = NSURL(string: redirectURLString) else {
            XCTFail()
            return
        }
        let handleRequest = NSURLRequest(URL: redirectURL)
        let baseAuthenticator = BaseAuthenticator(scopes: [])
        baseAuthenticator.loginCompletion = loginCompletionBlock
        
        XCTAssertTrue(baseAuthenticator.handleRedirectRequest(handleRequest))
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
