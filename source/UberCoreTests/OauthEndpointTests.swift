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
@testable import UberCore

class OauthEndpointTests: XCTestCase {
    
    // {redirect_to_login:true}
    let base64EncodedSignup = "eyJyZWRpcmVjdF90b19sb2dpbiI6dHJ1ZX0="
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testLogin_withSandboxEnabled() {
        Configuration.shared.isSandbox = true
        
        let scopes = [ UberScope.profile, UberScope.history ]
        let expectedHost = "https://auth.uber.com"
        let expectedPath = "/oauth/v2/authorize"
        let expectedScopes = scopes.toUberScopeString()
        let expectedClientID = Configuration.shared.clientID
        let expectedRedirect = Configuration.shared.getCallbackURI()
        let expectedTokenType = "token"
        
        let expectedQueryItems = [
            URLQueryItem(name: "scope", value: expectedScopes),
            URLQueryItem(name: "client_id", value: expectedClientID),
            URLQueryItem(name: "redirect_uri", value: expectedRedirect.absoluteString),
            URLQueryItem(name: "signup_params", value: base64EncodedSignup),
            URLQueryItem(name: "response_type", value: expectedTokenType)]
        
        let login = OAuth.implicitLogin(clientID: expectedClientID, scopes: scopes, redirect: expectedRedirect)
        
        XCTAssertEqual(login.host, expectedHost)
        XCTAssertEqual(login.path, expectedPath)
        XCTAssertEqual(login.query, expectedQueryItems)
    }

    func testLogin_withSandboxDisabled() {
        Configuration.shared.isSandbox = false
        
        let scopes = [ UberScope.profile, UberScope.history ]
        let expectedHost = "https://auth.uber.com"
        let expectedPath = "/oauth/v2/authorize"
        let expectedScopes = scopes.toUberScopeString()
        let expectedClientID = Configuration.shared.clientID
        let expectedRedirect = Configuration.shared.getCallbackURI()
        let expectedTokenType = "token"

        let expectedQueryItems = [
            URLQueryItem(name: "scope", value: expectedScopes),
            URLQueryItem(name: "client_id", value: expectedClientID),
            URLQueryItem(name: "redirect_uri", value: expectedRedirect.absoluteString),
            URLQueryItem(name: "signup_params", value: base64EncodedSignup),
            URLQueryItem(name: "response_type", value: expectedTokenType)]
        
        let login = OAuth.implicitLogin(clientID: expectedClientID, scopes: scopes, redirect: expectedRedirect)
        
        XCTAssertEqual(login.host, expectedHost)
        XCTAssertEqual(login.path, expectedPath)
        XCTAssertEqual(login.query, expectedQueryItems)
    }

    func testLogin_forAuthorizationCodeGrant_defaultSettings() {
        let scopes = [ UberScope.allTrips, UberScope.history ]
        let expectedHost = "https://auth.uber.com"
        let expectedPath = "/oauth/v2/authorize"
        let expectedScopes = scopes.toUberScopeString()
        let expectedClientID = Configuration.shared.clientID
        let expectedRedirect = Configuration.shared.getCallbackURI()
        let expectedTokenType = "code"
        let expectedState = "state123423"


        let expectedQueryItems = [
            URLQueryItem(name: "scope", value: expectedScopes),
            URLQueryItem(name: "client_id", value: expectedClientID),
            URLQueryItem(name: "redirect_uri", value: expectedRedirect.absoluteString),
            URLQueryItem(name: "signup_params", value: base64EncodedSignup),
            URLQueryItem(name: "response_type", value: expectedTokenType),
            URLQueryItem(name: "state", value: expectedState)]
        
        let login = OAuth.authorizationCodeLogin(clientID: expectedClientID, redirect: expectedRedirect, scopes: scopes, state: expectedState)
        
        XCTAssertEqual(login.host, expectedHost)
        XCTAssertEqual(login.path, expectedPath)
        XCTAssertEqual(login.query, expectedQueryItems)
    }
    
    func testPar_forResponseTypeCode_defaultSettings() {
        let expectedHost = "https://auth.uber.com"
        let expectedPath = "/oauth/v2/par"
        let expectedClientID = Configuration.shared.clientID
        let expectedResponseType = OAuth.ResponseType.code
        let expectedLoginHint: [String: String] = [
            "email": "test@test.com",
            "phone": "5555555555",
            "first_name": "First",
            "last_name": "Last"
        ]
        let expectedLoginHintString = try! JSONSerialization.data(withJSONObject: expectedLoginHint).base64EncodedString()

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: expectedClientID),
            URLQueryItem(name: "response_type", value: expectedResponseType.rawValue),
            URLQueryItem(name: "login_hint", value: expectedLoginHintString),
        ]
        let expectedQueryItems = components.query!
        
        let login = OAuth.par(clientID: expectedClientID, loginHint: expectedLoginHint, responseType: expectedResponseType)
        
        let queryString = String(data: login.body!, encoding: .utf8)
        
        XCTAssertEqual(login.host, expectedHost)
        XCTAssertEqual(login.path, expectedPath)
        XCTAssertEqual(queryString, expectedQueryItems)
    }
    
    func testPar_forResponseTypeToken_defaultSettings() {
        let expectedHost = "https://auth.uber.com"
        let expectedPath = "/oauth/v2/par"
        let expectedClientID = Configuration.shared.clientID
        let expectedResponseType = OAuth.ResponseType.token
        let expectedLoginHint: [String: String] = [
            "email": "test@test.com",
            "phone": "5555555555",
            "first_name": "First",
            "last_name": "Last"
        ]
        let expectedLoginHintString = try! JSONSerialization.data(withJSONObject: expectedLoginHint).base64EncodedString()

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: expectedClientID),
            URLQueryItem(name: "response_type", value: expectedResponseType.rawValue),
            URLQueryItem(name: "login_hint", value: expectedLoginHintString),
        ]
        let expectedQueryItems = components.query!
        
        let login = OAuth.par(clientID: expectedClientID, loginHint: expectedLoginHint, responseType: expectedResponseType)
        
        let queryString = String(data: login.body!, encoding: .utf8)
        
        XCTAssertEqual(login.host, expectedHost)
        XCTAssertEqual(login.path, expectedPath)
        XCTAssertEqual(queryString, expectedQueryItems)
    }
}
