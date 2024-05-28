//
//  TokenManagerTests.swift
//  UberCore
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
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

final class TokenManagerTests: XCTestCase {

    private let keychainUtility = KeychainUtilityProtocolMock()
    
    func test_saveToken_triggersKeychainUtilitySave() {
        
        keychainUtility.saveHandler = { _, identifier, _ -> Bool in
            XCTAssertEqual(identifier, "test_token_identifier")
            return true
        }
        
        let accessToken = AccessToken(
            tokenString: "test_token_string"
        )
        
        let tokenManager = TokenManager(
            keychainUtility: keychainUtility
        )
        
        XCTAssertEqual(keychainUtility.saveCallCount, 0)
        
        _ = tokenManager.saveToken(accessToken, identifier: "test_token_identifier")
        
        XCTAssertEqual(keychainUtility.saveCallCount, 1)
    }
    
    func test_saveToken() {
        let accessToken = AccessToken(tokenString: "test_token_string")
        let tokenManager = TokenManager()
        let result = tokenManager.saveToken(accessToken)
        
        XCTAssertTrue(result)
    }
    
    func test_getToken_triggersKeychainUtilityGet() {
        
        let accessToken = AccessToken(
            tokenString: "test_token_string"
        )
        
        keychainUtility.getHandler = { identifier, _ -> AccessToken? in
            XCTAssertEqual(identifier, "test_token_identifier")
            return accessToken
        }
        
        let tokenManager = TokenManager(
            keychainUtility: keychainUtility
        )
        
        XCTAssertEqual(keychainUtility.getCallCount, 0)
        
        let token = tokenManager.getToken(identifier: "test_token_identifier")
        
        XCTAssertEqual(accessToken, token)
        XCTAssertEqual(keychainUtility.getCallCount, 1)
    }
    
    func test_getToken() {
        
        var savedToken: AccessToken?
        keychainUtility.saveHandler = { value, _, _ in
            savedToken = value as? AccessToken
            return true
        }
        
        keychainUtility.getHandler = { key, _ in
            XCTAssertEqual(key, TokenManager.defaultAccessTokenIdentifier)
            return savedToken
        }
        
        let accessToken = AccessToken(tokenString: "test_token_string")
        let tokenManager = TokenManager(
            keychainUtility: keychainUtility
        )
        tokenManager.saveToken(accessToken)
        
        let token = tokenManager.getToken()
        XCTAssertEqual(token, accessToken)
    }
    
    func test_deleteToken_triggersKeychainUtilityDelete() {
        
        keychainUtility.deleteHandler = { identifier, _ -> Bool in
            XCTAssertEqual(identifier, "test_token_identifier")
            return true
        }
        
        let tokenManager = TokenManager(
            keychainUtility: keychainUtility
        )
        
        XCTAssertEqual(keychainUtility.deleteCallCount, 0)
        
        tokenManager.deleteToken(identifier: "test_token_identifier")
        
        XCTAssertEqual(keychainUtility.deleteCallCount, 1)
    }
    
    func test_deleteToken() {
        let accessToken = AccessToken(tokenString: "test_token_string")
        let tokenManager = TokenManager()
        
        tokenManager.saveToken(accessToken)
        
        let deleted = tokenManager.deleteToken()
        XCTAssertTrue(deleted)
        
        let token = tokenManager.getToken()
        XCTAssertNil(token)
    }
    
    func test_deleteToken_noneSaved() {
        let tokenManager = TokenManager()
        
        let deleted = tokenManager.deleteToken()
        XCTAssertFalse(deleted)
        
        let token = tokenManager.getToken()
        XCTAssertNil(token)
    }
    
    func testCookiesCleared_whenTokenDeleted() {
        guard let usUrl = URL(string: "https://login.uber.com")  else {
            XCTAssertFalse(false)
            return
        }
        
        let cookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieStorage.cookies {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
        
        cookieStorage.setCookies(createTestUSCookies(), for: usUrl, mainDocumentURL: nil)
        UserDefaults.standard.synchronize()
        
        XCTAssertEqual(cookieStorage.cookies!.count, 2)
        XCTAssertEqual(cookieStorage.cookies(for: usUrl)!.count, 2)
        
        let accessToken = AccessToken(tokenString: "test_token_string")
        let tokenManager = TokenManager()

        tokenManager.saveToken(accessToken)
        tokenManager.deleteToken()
        
        XCTAssertEqual(cookieStorage.cookies!.count, 0)
        XCTAssertEqual(cookieStorage.cookies(for: usUrl)!.count, 0)
    }
    
    // MARK: Helpers
            
    func createTestUSCookies() -> [HTTPCookie] {
        let secureUSCookie = HTTPCookie(
            properties: [HTTPCookiePropertyKey.domain: ".uber.com",
            HTTPCookiePropertyKey.path : "/",
            HTTPCookiePropertyKey.name : "us_login_secure",
            HTTPCookiePropertyKey.value : "some_value",
            HTTPCookiePropertyKey.secure : true]
        )
        let unsecureUSCookie = HTTPCookie(
            properties: [HTTPCookiePropertyKey.domain: ".uber.com",
            HTTPCookiePropertyKey.path : "/",
            HTTPCookiePropertyKey.name : "us_login_unecure",
            HTTPCookiePropertyKey.value : "some_value",
            HTTPCookiePropertyKey.secure : false]
        )
        if let secureUSCookie = secureUSCookie, 
            let unsecureUSCookie = unsecureUSCookie {
            return [secureUSCookie, unsecureUSCookie]
        }
        return []
    }
}
