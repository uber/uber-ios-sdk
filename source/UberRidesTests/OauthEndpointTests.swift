//
//  OauthEndpointTests.swift
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

class OauthEndpointTests: XCTestCase {
    
    // {redirect_to_login:true}
    let base64EncodedSignup = "eyJyZWRpcmVjdF90b19sb2dpbiI6dHJ1ZX0="
    
    override func setUp() {
        super.setUp()
        Configuration.bundle = Bundle(for: type(of: self))
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testLogin_withSandboxEnabled() {
        Configuration.shared.isSandbox = true
        
        let scopes = [ RidesScope.profile, RidesScope.history ]
        let expectedHost = "https://login.uber.com"
        let expectedPath = "/oauth/v2/authorize"
        let expectedScopes = scopes.toRidesScopeString()
        let expectedClientID = Configuration.shared.clientID
        let expectedRedirect = Configuration.shared.getCallbackURIString()
        let expectedTokenType = "token"
        
        let expectedQueryItems = queryBuilder(
            ("scope", expectedScopes),
            ("client_id", expectedClientID),
            ("redirect_uri", expectedRedirect),
            ("signup_params", base64EncodedSignup),
            ("response_type", expectedTokenType))
        
        let login = OAuth.implicitLogin(clientID: expectedClientID, scopes: scopes, redirect: expectedRedirect)
        
        XCTAssertEqual(login.host, expectedHost)
        XCTAssertEqual(login.path, expectedPath)
        XCTAssertEqual(login.query, expectedQueryItems)
    }

    func testLogin_withSandboxDisabled() {
        Configuration.shared.isSandbox = false
        
        let scopes = [ RidesScope.profile, RidesScope.history ]
        let expectedHost = "https://login.uber.com"
        let expectedPath = "/oauth/v2/authorize"
        let expectedScopes = scopes.toRidesScopeString()
        let expectedClientID = Configuration.shared.clientID
        let expectedRedirect = Configuration.shared.getCallbackURIString()
        let expectedTokenType = "token"
        
        let expectedQueryItems = queryBuilder(
            ("scope", expectedScopes),
            ("client_id", expectedClientID),
            ("redirect_uri", expectedRedirect),
            ("signup_params", base64EncodedSignup),
            ("response_type", expectedTokenType))
        
        let login = OAuth.implicitLogin(clientID: expectedClientID, scopes: scopes, redirect: expectedRedirect)
        
        XCTAssertEqual(login.host, expectedHost)
        XCTAssertEqual(login.path, expectedPath)
        XCTAssertEqual(login.query, expectedQueryItems)
    }

    func testLogin_forAuthorizationCodeGrant_defaultSettings() {
        let scopes = [ RidesScope.allTrips, RidesScope.history ]
        let expectedHost = "https://login.uber.com"
        let expectedPath = "/oauth/v2/authorize"
        let expectedScopes = scopes.toRidesScopeString()
        let expectedClientID = Configuration.shared.clientID
        let expectedRedirect = Configuration.shared.getCallbackURIString()
        let expectedTokenType = "code"
        let expectedState = "state123423"
        
        let expectedQueryItems = queryBuilder(
            ("scope", expectedScopes),
            ("client_id", expectedClientID),
            ("redirect_uri", expectedRedirect),
            ("signup_params", base64EncodedSignup),
            ("response_type", expectedTokenType),
            ("state", expectedState))
        
        let login = OAuth.authorizationCodeLogin(clientID: expectedClientID, redirect: expectedRedirect, scopes: scopes, state: expectedState)
        
        XCTAssertEqual(login.host, expectedHost)
        XCTAssertEqual(login.path, expectedPath)
        XCTAssertEqual(login.query, expectedQueryItems)
    }
}
