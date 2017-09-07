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
    private let timeout: TimeInterval = 2
    private let tokenString = "accessToken1234"
    private var redirectURI: String = ""
    
    override func setUp() {
        super.setUp()
        Configuration.bundle = Bundle(for: type(of: self))
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        redirectURI = Configuration.shared.getCallbackURIString(for: .general)
    }
    
    override func tearDown() {
        _ = TokenManager.deleteToken()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testBaseAuthenticator_usesGeneralCallback() {
        let baseAuthenticator = BaseAuthenticator(scopes: [])
        XCTAssertEqual(baseAuthenticator.callbackURIType, CallbackURIType.general)
    }
    
    func testBaseAuthenticator_correctlySavesScopes() {
        let scopes = [RidesScope.profile, RidesScope.allTrips]
        let baseAuthenticator = BaseAuthenticator(scopes: scopes)
        XCTAssertEqual(scopes, baseAuthenticator.scopes);
    }
    
    func testBaseAuthenticator_handleRedirectFalse_whenURLNil() {
        guard let url = URL(string:"test.url") else {
            XCTFail("invalid url")
            return
        }
        var emptyRequest = URLRequest(url: url)
        emptyRequest.url = nil
        let baseAuthenticator = BaseAuthenticator(scopes: [])
        XCTAssertFalse(baseAuthenticator.handleRedirect(for: emptyRequest))
    }
    
    func testBaseAuthenticator_handleRedirectFalse_whenURLNotRedirect() {
        let redirectURLString = "testURI://redirect"
        let notRedirectURLString = "testURI://notRedirect"
        Configuration.shared.setCallbackURIString(redirectURLString, type: .general)
        guard let notRedirectURL = URL(string: notRedirectURLString) else {
            XCTFail()
            return
        }
        let handleRequest = URLRequest(url: notRedirectURL)
        let baseAuthenticator = BaseAuthenticator(scopes: [])
        XCTAssertFalse(baseAuthenticator.handleRedirect(for: handleRequest))
    }
    
    func testBaseAuthenticator_handleRedirectTrue_whenValidRedirect() {
        self.expectation = expectation(description: "Login completion called")
        
        let loginCompletionBlock: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { (_,_) in
            self.expectation.fulfill()
        }
        
        let redirectURLString = "testURI://redirect?error=server_error"
        Configuration.shared.setCallbackURIString(redirectURLString, type: .general)
        guard let redirectURL = URL(string: redirectURLString) else {
            XCTFail()
            return
        }
        let handleRequest = URLRequest(url: redirectURL)
        let baseAuthenticator = BaseAuthenticator(scopes: [])
        baseAuthenticator.loginCompletion = loginCompletionBlock
        
        XCTAssertTrue(baseAuthenticator.handleRedirect(for: handleRequest))
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
