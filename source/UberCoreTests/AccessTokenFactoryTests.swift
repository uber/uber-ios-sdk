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
@testable import UberCore

class AccessTokenFactoryTests: XCTestCase {
    private let redirectURI = "http://localhost:1234/"
    private let tokenString = "token"
    private let tokenTypeString = "type"
    private let refreshTokenString = "refreshToken"
    private let expirationTime = 10030.23
    private let allowedScopesString = "profile history"
    private let errorString = "invalid_parameters"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseTokenFromURL_withSuccess() {
        var components = URLComponents()
        components.fragment = "access_token=\(tokenString)&refresh_token=\(refreshTokenString)&token_type=\(tokenTypeString)&expires_in=\(expirationTime)&scope=\(allowedScopesString)"
        components.host = redirectURI
        guard let url = components.url else {
            XCTAssert(false)
            return
        }
        do {
            let token : AccessToken = try AccessTokenFactory.createAccessToken(fromRedirectURL: url)
            XCTAssertNotNil(token)
            XCTAssertEqual(token.tokenString, tokenString)
            XCTAssertEqual(token.refreshToken, refreshTokenString)
            XCTAssertEqual(token.tokenType, tokenTypeString)
            XCTAssertEqual(token.grantedScopes.toUberScopeString(), allowedScopesString)
            UBSDKAssert(date: token.expirationDate!, approximatelyIn: expirationTime)
            
        } catch _ as NSError {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withError() {
        var components = URLComponents()
        components.fragment = "access_token=\(tokenString)&refresh_token=\(refreshTokenString)&token_type=\(tokenTypeString)&expires_in=\(expirationTime)&scope=\(allowedScopesString)&error=\(errorString)"
        components.host = redirectURI
        guard let url = components.url else {
            XCTAssert(false)
            return
        }
        do {
            _ = try AccessTokenFactory.createAccessToken(fromRedirectURL: url)
            XCTFail("Didn't parse out error")
        } catch let error as NSError {
            XCTAssertEqual(error.code, UberAuthenticationErrorType.invalidRequest.rawValue)
            XCTAssertEqual(error.domain, UberAuthenticationErrorFactory.errorDomain)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withOnlyError() {
        var components = URLComponents()
        components.fragment = "error=\(errorString)"
        components.host = redirectURI
        guard let url = components.url else {
            XCTAssert(false)
            return
        }
        do {
            _ = try AccessTokenFactory.createAccessToken(fromRedirectURL: url)
            XCTFail("Didn't parse out error")
        } catch let error as NSError {
            XCTAssertEqual(error.code, UberAuthenticationErrorType.invalidRequest.rawValue)
            XCTAssertEqual(error.domain, UberAuthenticationErrorFactory.errorDomain)
        } catch  {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withPartialParameters() {
        var components = URLComponents()
        components.fragment = "access_token=\(tokenString)"
        components.host = redirectURI
        guard let url = components.url else {
            XCTAssert(false)
            return
        }
        do {
            let token : AccessToken = try AccessTokenFactory.createAccessToken(fromRedirectURL: url)
            XCTAssertNotNil(token)
            XCTAssertEqual(token.tokenString, tokenString)
            XCTAssertNil(token.refreshToken)
            XCTAssertNil(token.tokenType)
            XCTAssertNil(token.expirationDate)
            XCTAssertEqual(token.grantedScopes, [UberScope]())
        } catch _ as NSError {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withFragmentAndQuery_withError() {
        var components = URLComponents()
        components.fragment = "access_token=\(tokenString)"
        components.query = "error=\(errorString)"
        components.host = redirectURI
        guard let url = components.url else {
            XCTAssert(false)
            return
        }
        do {
            _ = try AccessTokenFactory.createAccessToken(fromRedirectURL: url)
            XCTFail("Didn't parse out error")
        } catch let error as NSError {
            XCTAssertEqual(error.code, UberAuthenticationErrorType.invalidRequest.rawValue)
            XCTAssertEqual(error.domain, UberAuthenticationErrorFactory.errorDomain)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withFragmentAndQuery_withSuccess() {
        var components = URLComponents(string: redirectURI)!
        components.fragment = "access_token=\(tokenString)&refresh_token=\(refreshTokenString)&token_type=\(tokenTypeString)"
        components.query = "expires_in=\(expirationTime)&scope=\(allowedScopesString)"
        guard let url = components.url else {
            XCTAssert(false)
            return
        }
        do {
            let token : AccessToken = try AccessTokenFactory.createAccessToken(fromRedirectURL: url)
            XCTAssertNotNil(token)
            XCTAssertEqual(token.tokenString, tokenString)
            XCTAssertEqual(token.tokenType, tokenTypeString)
            XCTAssertEqual(token.refreshToken, refreshTokenString)
            XCTAssertEqual(token.grantedScopes.toUberScopeString(), allowedScopesString)
            UBSDKAssert(date: token.expirationDate!, approximatelyIn: expirationTime)
            
        } catch {
            XCTAssert(false)
        }
    }
    
    func testParseTokenFromURL_withInvalidFragment() {
        var components = URLComponents()
        components.fragment = "access_token=\(tokenString)&refresh_token"
        components.host = redirectURI
        guard let url = components.url else {
            XCTAssert(false)
            return
        }
        do {
            let token : AccessToken = try AccessTokenFactory.createAccessToken(fromRedirectURL: url)
            XCTAssertNotNil(token)
            XCTAssertEqual(token.tokenString, tokenString)
            XCTAssertNil(token.tokenType)
            XCTAssertNil(token.refreshToken)
            XCTAssertNil(token.expirationDate)
            XCTAssertEqual(token.grantedScopes, [UberScope]())
        } catch _ as NSError {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
    }

    func testParseValidJsonStringToAccessToken() {
        let jsonString = "{\"access_token\": \"\(tokenString)\", \"refresh_token\": \"\(refreshTokenString)\", \"token_type\": \"\(tokenTypeString)\", \"expires_in\": \"\(expirationTime)\", \"scope\": \"\(allowedScopesString)\"}"

        guard let accessToken = try? AccessTokenFactory.createAccessToken(fromJSONData: jsonString.data(using: .utf8)!) else {
            XCTFail()
            return
        }
        XCTAssertEqual(accessToken.tokenString, tokenString)
        XCTAssertEqual(accessToken.refreshToken, refreshTokenString)
        XCTAssertEqual(accessToken.tokenType, tokenTypeString)
        UBSDKAssert(date: accessToken.expirationDate!, approximatelyIn: expirationTime)
        XCTAssert(accessToken.grantedScopes.contains(UberScope.profile))
        XCTAssert(accessToken.grantedScopes.contains(UberScope.history))
    }
    
    func testParseInvalidJsonStringToAccessToken() {
        let tokenString = "tokenString1234"
        let jsonString = "{\"access_token\": \"\(tokenString)\""
        let accessToken = try? AccessTokenFactory.createAccessToken(fromJSONData: jsonString.data(using: .utf8)!)
        
        XCTAssertNil(accessToken)
    }
}
