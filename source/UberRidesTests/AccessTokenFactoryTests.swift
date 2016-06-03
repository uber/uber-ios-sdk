//
//  AccessTokenFactorytests.swift
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

class AccessTokenFactoryTests: XCTestCase {
    private let redirectURI = "http://localhost:1234/"
    private let tokenString = "token"
    private let refreshTokenString = "refreshToken"
    private let expirationTime = 10030.23
    private let allowedScopesString = "profile history"
    private let errorString = "invalid_parameters"
    
    private let maxExpirationDifference = 2.0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseTokenFromURL_withSuccess() {
        let components = NSURLComponents()
        components.fragment = "access_token=\(tokenString)&refresh_token=\(refreshTokenString)&expires_in=\(expirationTime)&scope=\(allowedScopesString)"
        components.host = redirectURI
        guard let url = components.URL else {
            XCTAssert(false)
            return
        }
        do {
            let expectedExpirationInterval = NSDate().timeIntervalSince1970 + expirationTime
            
            let token : AccessToken = try AccessTokenFactory.createAccessTokenFromRedirectURL(url)
            XCTAssertNotNil(token)
            XCTAssertEqual(token.tokenString, tokenString)
            XCTAssertEqual(token.refreshToken, refreshTokenString)
            XCTAssertEqual(token.grantedScopes?.toRidesScopeString(), allowedScopesString)
            
            guard let expiration = token.expirationDate?.timeIntervalSince1970 else {
                XCTAssert(false)
                return
            }
            
            let timeDiff = abs(expiration - expectedExpirationInterval)
            XCTAssertLessThanOrEqual(timeDiff, maxExpirationDifference)
            
        } catch _ as NSError {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withError() {
        let components = NSURLComponents()
        components.fragment = "access_token=\(tokenString)&refresh_token=\(refreshTokenString)&expires_in=\(expirationTime)&scope=\(allowedScopesString)&error=\(errorString)"
        components.host = redirectURI
        guard let url = components.URL else {
            XCTAssert(false)
            return
        }
        do {
            try AccessTokenFactory.createAccessTokenFromRedirectURL(url)
        } catch let error as NSError {
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.InvalidRequest.rawValue)
            XCTAssertEqual(error.domain, RidesAuthenticationErrorFactory.errorDomain)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withOnlyError() {
        let components = NSURLComponents()
        components.fragment = "error=\(errorString)"
        components.host = redirectURI
        guard let url = components.URL else {
            XCTAssert(false)
            return
        }
        do {
            try AccessTokenFactory.createAccessTokenFromRedirectURL(url)
        } catch let error as NSError {
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.InvalidRequest.rawValue)
            XCTAssertEqual(error.domain, RidesAuthenticationErrorFactory.errorDomain)
        } catch  {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withPartialParameters() {
        let components = NSURLComponents()
        components.fragment = "access_token=\(tokenString)"
        components.host = redirectURI
        guard let url = components.URL else {
            XCTAssert(false)
            return
        }
        do {
            let token : AccessToken = try AccessTokenFactory.createAccessTokenFromRedirectURL(url)
            XCTAssertNotNil(token)
            XCTAssertEqual(token.tokenString, tokenString)
            XCTAssertNil(token.refreshToken)
            XCTAssertNil(token.expirationDate)
            XCTAssertEqual(token.grantedScopes!, [RidesScope]())
        } catch _ as NSError {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withFragmentAndQuery_withError() {
        let components = NSURLComponents()
        components.fragment = "access_token=\(tokenString)"
        components.query = "error=\(errorString)"
        components.host = redirectURI
        guard let url = components.URL else {
            XCTAssert(false)
            return
        }
        do {
            try AccessTokenFactory.createAccessTokenFromRedirectURL(url)
        } catch let error as NSError {
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.InvalidRequest.rawValue)
            XCTAssertEqual(error.domain, RidesAuthenticationErrorFactory.errorDomain)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withFragmentAndQuery_withSuccess() {
        let components = NSURLComponents()
        components.fragment = "access_token=\(tokenString)&refresh_token=\(refreshTokenString)"
        components.query = "expires_in=\(expirationTime)&scope=\(allowedScopesString)"
        components.host = redirectURI
        guard let url = components.URL else {
            XCTAssert(false)
            return
        }
        do {
            let expectedExpirationInterval = NSDate().timeIntervalSince1970 + expirationTime
            
            let token : AccessToken = try AccessTokenFactory.createAccessTokenFromRedirectURL(url)
            XCTAssertNotNil(token)
            XCTAssertEqual(token.tokenString, tokenString)
            XCTAssertEqual(token.refreshToken, refreshTokenString)
            XCTAssertEqual(token.grantedScopes?.toRidesScopeString(), allowedScopesString)
            
            guard let expiration = token.expirationDate?.timeIntervalSince1970 else {
                XCTAssert(false)
                return
            }
            
            let timeDiff = abs(expiration - expectedExpirationInterval)
            XCTAssertLessThanOrEqual(timeDiff, maxExpirationDifference)
            
        } catch _ as NSError {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withInvalidFragment() {
        let components = NSURLComponents()
        components.fragment = "access_token=\(tokenString)&refresh_token"
        components.host = redirectURI
        guard let url = components.URL else {
            XCTAssert(false)
            return
        }
        do {
            let token : AccessToken = try AccessTokenFactory.createAccessTokenFromRedirectURL(url)
            XCTAssertNotNil(token)
            XCTAssertEqual(token.tokenString, tokenString)
            XCTAssertNil(token.refreshToken)
            XCTAssertNil(token.expirationDate)
            XCTAssertEqual(token.grantedScopes!, [RidesScope]())
        } catch _ as NSError {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
    }

    func testParseValidJsonStringToAccessToken() {
        let tokenString = "tokenString1234"
        let jsonString = "{\"access_token\": \"\(tokenString)\"}"
        let accessToken = AccessTokenFactory.createAccessTokenFromJSONString(jsonString)
        
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.tokenString, tokenString)
    }
    
    func testParseInvalidJsonStringToAccessToken() {
        let tokenString = "tokenString1234"
        let jsonString = "{\"access_token\": \"\(tokenString)\""
        let accessToken = AccessTokenFactory.createAccessTokenFromJSONString(jsonString)
        
        XCTAssertNil(accessToken)
    }
}
