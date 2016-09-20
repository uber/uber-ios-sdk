//
//  TokenManagerTests.swift
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

class TokenManagerTests: XCTestCase {
    
    fileprivate var notificationFired = false
    fileprivate var keychain: KeychainWrapper?
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.bundle = Bundle(forClass: type(of: self))
        keychain = KeychainWrapper()
        notificationFired = false
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        keychain = nil
        super.tearDown()
    }
    
    
    func testSave() {
        let identifier = "testIdentifier"
        let accessGroup = "testAccessGroup"
        
        let token = getTestToken()
        
        XCTAssertTrue(TokenManager.saveToken(token, tokenIdentifier:identifier, accessGroup: accessGroup))
        
        keychain?.setAccessGroup(accessGroup)
        guard let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(actualToken.tokenString, token.tokenString)
        
        
        keychain?.deleteObjectForKey(identifier)
        
    }
    
    func testSave_firesNotification() {
        let identifier = "testIdentifier"
        let accessGroup = "testAccessGroup"
        
        let token = getTestToken()
        
        NotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleTokenManagerNotifications), name: TokenManager.TokenManagerDidSaveTokenNotification, object: nil)
        
        XCTAssertTrue(TokenManager.saveToken(token, tokenIdentifier:identifier, accessGroup: accessGroup))
        
        NotificationCenter.default.removeObserver(self)
        
        keychain?.setAccessGroup(accessGroup)
        guard let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(actualToken.tokenString, token.tokenString)
        
        XCTAssertTrue(notificationFired)
        
        keychain?.deleteObjectForKey(identifier)
        
    }
    
    func testGet() {
        
        let identifier = "testIdentifier"
        let accessGroup = "testAccessGroup"
        
        let token = getTestToken()
        
        keychain?.setAccessGroup(accessGroup)
        keychain?.setObject(token, key: identifier)
        
        let actualToken = TokenManager.fetchToken(identifier, accessGroup: accessGroup)
        XCTAssertNotNil(actualToken)
        
        XCTAssertEqual(actualToken?.tokenString, token.tokenString)
        
        keychain?.deleteObjectForKey(identifier)
    }
    
    func testGet_nonExistent() {
        let identifer = "there.is.no.token.named.this.123412wfdasd3o"
        
        XCTAssertNil(TokenManager.fetchToken(identifer))
    }
    
    func testDelete() {
        let identifier = "testIdentifier"
        let accessGroup = "testAccessGroup"
        
        let token = getTestToken()
        
        keychain?.setAccessGroup(accessGroup)
        keychain?.setObject(token, key: identifier)
        
        XCTAssertTrue(TokenManager.deleteToken(identifier, accessGroup: accessGroup))
        
        let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken
        guard actualToken == nil else {
            XCTAssert(false)
            keychain?.deleteObjectForKey(identifier)
            return
        }
    }
    
    func testDelete_nonExistent() {
        let identifier = "there.is.no.token.named.this.123412wfdasd3o"
        
        XCTAssertFalse(TokenManager.deleteToken(identifier))
        
    }
    
    func testDelete_firesNotification() {
        
        let identifier = "testIdentifier"
        let accessGroup = "testAccessGroup"
        
        let token = getTestToken()
        
        keychain?.setAccessGroup(accessGroup)
        keychain?.setObject(token, key: identifier)
        
        NotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleTokenManagerNotifications), name: TokenManager.TokenManagerDidDeleteTokenNotification, object: nil)
        
        XCTAssertTrue(TokenManager.deleteToken(identifier, accessGroup: accessGroup))
        
        NotificationCenter.default.removeObserver(self)
        
        XCTAssertTrue(notificationFired)
        
        let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken
        guard actualToken == nil else {
            XCTAssert(false)
            keychain?.deleteObjectForKey(identifier)
            return
        }
    }
    
    func testDelete_nonExistent_doesNotFireNotification() {
        let identifier = "there.is.no.token.named.this.123412wfdasd3o"
        
        NotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleTokenManagerNotifications), name: TokenManager.TokenManagerDidDeleteTokenNotification, object: nil)
        
        XCTAssertFalse(TokenManager.deleteToken(identifier))
        
        NotificationCenter.default.removeObserver(self)
        
        XCTAssertFalse(notificationFired)
    }
    
    func testCookiesCleared_whenTokenDeleted() {
        guard let usUrl = URL(string: "https://login.uber.com"), let chinaURL = URL(string: "https://login.uber.com.cn")  else {
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
        cookieStorage.setCookies(createTestChinaCookies(), for: chinaURL, mainDocumentURL: nil)
        UserDefaults.standard.synchronize()
        XCTAssertEqual(cookieStorage.cookies?.count, 4)
        XCTAssertEqual(cookieStorage.cookies(for: usUrl)?.count, 2)
        XCTAssertEqual(cookieStorage.cookies(for: chinaURL)?.count, 2)
        
        let identifier = "testIdentifier"
        let accessGroup = "testAccessGroup"
        
        let token = getTestToken()
        
        keychain?.setAccessGroup(accessGroup)
        keychain?.setObject(token, key: identifier)
        
        XCTAssertTrue(TokenManager.deleteToken(identifier, accessGroup: accessGroup))
        
        let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken
        guard actualToken == nil else {
            XCTAssert(false)
            keychain?.deleteObjectForKey(identifier)
            return
        }
        
        let testCookieStorage = HTTPCookieStorage.shared
        XCTAssertEqual(testCookieStorage.cookies?.count, 0)
        
    }
    
    
    //MARK: Helpers
    
    func getTestToken() -> AccessToken! {
        let tokenData = ["access_token" : "testTokenString"]
        return AccessToken(JSON: tokenData)
    }
            
    func createTestUSCookies() -> [HTTPCookie] {
        let secureUSCookie = HTTPCookie(properties: [HTTPCookiePropertyKey.domain: ".uber.com",
            HTTPCookiePropertyKey.path : "/",
            HTTPCookiePropertyKey.name : "us_login_secure",
            HTTPCookiePropertyKey.value : "some_value",
            HTTPCookiePropertyKey.secure : true])
        let unsecureUSCookie = HTTPCookie(properties: [HTTPCookiePropertyKey.domain: ".uber.com",
            HTTPCookiePropertyKey.path : "/",
            HTTPCookiePropertyKey.name : "us_login_unecure",
            HTTPCookiePropertyKey.value : "some_value",
            HTTPCookiePropertyKey.secure : false])
        if let secureUSCookie = secureUSCookie, let unsecureUSCookie = unsecureUSCookie {
            return [secureUSCookie, unsecureUSCookie]
        }
        return []
    }
    
    func createTestChinaCookies() -> [HTTPCookie] {
        let secureChinaCookie = HTTPCookie(properties: [HTTPCookiePropertyKey.domain : ".uber.com.cn",
            HTTPCookiePropertyKey.path : "/",
            HTTPCookiePropertyKey.name : "cn_login_secure",
            HTTPCookiePropertyKey.value : "some_value",
            HTTPCookiePropertyKey.secure : true])
        let unsecureChinaCookie  = HTTPCookie(properties: [HTTPCookiePropertyKey.domain : ".uber.com.cn",
            HTTPCookiePropertyKey.path : "/",
            HTTPCookiePropertyKey.name : "cn_login_unsecure",
            HTTPCookiePropertyKey.value : "some_value",
            HTTPCookiePropertyKey.secure : false])
        if let secureChinaCookie = secureChinaCookie, let unsecureChinaCookie = unsecureChinaCookie {
            return [secureChinaCookie, unsecureChinaCookie]
        }
        return []
    }
    
    func handleTokenManagerNotifications() {
        notificationFired = true
    }
}
