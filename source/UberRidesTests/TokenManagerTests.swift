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
    
    private var notificationFired = false
    private var keychain: KeychainWrapper?
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
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
        
        let token = getTestToken()
        
        XCTAssertTrue(TokenManager.saveToken(token, tokenIdentifier:identifier))

        guard let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken else {
            XCTFail("Unable to fetch token")
            return
        }
        XCTAssertEqual(actualToken.tokenString, token.tokenString)
        
        
        XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
        
    }
    
    func testSave_firesNotification() {
        let identifier = "testIdentifier"
        
        let token = getTestToken()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleTokenManagerNotifications), name: TokenManager.TokenManagerDidSaveTokenNotification, object: nil)
        
        XCTAssertTrue(TokenManager.saveToken(token, tokenIdentifier:identifier))
        
        NSNotificationCenter.defaultCenter().removeObserver(self)

        guard let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken else {
            XCTFail("Unable to fetch token")
            return
        }
        XCTAssertEqual(actualToken.tokenString, token.tokenString)
        
        XCTAssertTrue(notificationFired)
        
        XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
        
    }
    
    func testGet() {
        
        let identifier = "testIdentifier"
        
        let token = getTestToken()

        XCTAssertTrue(keychain!.setObject(token, key: identifier))
        
        let actualToken = TokenManager.fetchToken(identifier)
        XCTAssertNotNil(actualToken)
        
        XCTAssertEqual(actualToken?.tokenString, token.tokenString)
        
        XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
    }
    
    func testGet_nonExistent() {
        let identifer = "there.is.no.token.named.this.123412wfdasd3o"
        
        XCTAssertNil(TokenManager.fetchToken(identifer))
    }
    
    func testDelete() {
        let identifier = "testIdentifier"
        
        let token = getTestToken()

        XCTAssertTrue(keychain!.setObject(token, key: identifier))
        
        XCTAssertTrue(TokenManager.deleteToken(identifier))
        
        let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken
        guard actualToken == nil else {
            XCTFail("Token should have been deleted")
            XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
            return
        }
    }
    
    func testDelete_nonExistent() {
        let identifier = "there.is.no.token.named.this.123412wfdasd3o"
        
        XCTAssertFalse(TokenManager.deleteToken(identifier))
        
    }
    
    func testDelete_firesNotification() {
        
        let identifier = "testIdentifier"
        
        let token = getTestToken()

        XCTAssertTrue(keychain!.setObject(token, key: identifier))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleTokenManagerNotifications), name: TokenManager.TokenManagerDidDeleteTokenNotification, object: nil)
        
        XCTAssertTrue(TokenManager.deleteToken(identifier))
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        XCTAssertTrue(notificationFired)
        
        let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken
        guard actualToken == nil else {
            XCTFail("Token should have been deleted")
            XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
            return
        }
    }
    
    func testDelete_nonExistent_doesNotFireNotification() {
        let identifier = "there.is.no.token.named.this.123412wfdasd3o"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleTokenManagerNotifications), name: TokenManager.TokenManagerDidDeleteTokenNotification, object: nil)
        
        XCTAssertFalse(TokenManager.deleteToken(identifier))
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        XCTAssertFalse(notificationFired)
    }
    
    func testCookiesCleared_whenTokenDeleted() {
        guard let usUrl = NSURL(string: "https://login.uber.com"), let chinaURL = NSURL(string: "https://login.uber.com.cn")  else {
            XCTAssertFalse(false)
            return
        }
        
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        if let cookies = cookieStorage.cookies {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
        
        
        cookieStorage.setCookies(createTestUSCookies(), forURL: usUrl, mainDocumentURL: nil)
        cookieStorage.setCookies(createTestChinaCookies(), forURL: chinaURL, mainDocumentURL: nil)
        NSUserDefaults.standardUserDefaults().synchronize()
        XCTAssertEqual(cookieStorage.cookies?.count, 4)
        XCTAssertEqual(cookieStorage.cookiesForURL(usUrl)?.count, 2)
        XCTAssertEqual(cookieStorage.cookiesForURL(chinaURL)?.count, 2)
        
        let identifier = "testIdentifier"
        
        let token = getTestToken()

        keychain?.setObject(token, key: identifier)
        
        XCTAssertTrue(TokenManager.deleteToken(identifier))
        
        let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken
        guard actualToken == nil else {
            XCTAssert(false)
            keychain?.deleteObjectForKey(identifier)
            return
        }
        
        let testCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        XCTAssertEqual(testCookieStorage.cookies?.count, 0)
        
    }
    
    
    //MARK: Helpers
    
    func getTestToken() -> AccessToken! {
        let tokenData = ["access_token" : "testTokenString"]
        return AccessToken(JSON: tokenData)
    }
            
    func createTestUSCookies() -> [NSHTTPCookie] {
        let secureUSCookie = NSHTTPCookie(properties: [NSHTTPCookieDomain: ".uber.com",
            NSHTTPCookiePath : "/",
            NSHTTPCookieName : "us_login_secure",
            NSHTTPCookieValue : "some_value",
            NSHTTPCookieSecure : true])
        let unsecureUSCookie = NSHTTPCookie(properties: [NSHTTPCookieDomain: ".uber.com",
            NSHTTPCookiePath : "/",
            NSHTTPCookieName : "us_login_unecure",
            NSHTTPCookieValue : "some_value",
            NSHTTPCookieSecure : false])
        if let secureUSCookie = secureUSCookie, let unsecureUSCookie = unsecureUSCookie {
            return [secureUSCookie, unsecureUSCookie]
        }
        return []
    }
    
    func createTestChinaCookies() -> [NSHTTPCookie] {
        let secureChinaCookie = NSHTTPCookie(properties: [NSHTTPCookieDomain : ".uber.com.cn",
            NSHTTPCookiePath : "/",
            NSHTTPCookieName : "cn_login_secure",
            NSHTTPCookieValue : "some_value",
            NSHTTPCookieSecure : true])
        let unsecureChinaCookie  = NSHTTPCookie(properties: [NSHTTPCookieDomain : ".uber.com.cn",
            NSHTTPCookiePath : "/",
            NSHTTPCookieName : "cn_login_unsecure",
            NSHTTPCookieValue : "some_value",
            NSHTTPCookieSecure : false])
        if let secureChinaCookie = secureChinaCookie, let unsecureChinaCookie = unsecureChinaCookie {
            return [secureChinaCookie, unsecureChinaCookie]
        }
        return []
    }
    
    func handleTokenManagerNotifications() {
        notificationFired = true
    }
}
