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
@testable import UberCore

class TokenManagerTests: XCTestCase {
    
    private var notificationFired = false
    private var keychain: KeychainWrapper?
    private var token: AccessToken!
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        keychain = KeychainWrapper()
        notificationFired = false
        token = AccessToken(tokenString: "testTokenString")
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        keychain = nil
        super.tearDown()
    }
    
    
    func testSave() {
        let identifier = "testIdentifier"

        XCTAssertTrue(TokenManager.save(accessToken: token!, tokenIdentifier:identifier))

        guard let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken else {
            XCTFail("Unable to fetch token")
            return
        }
        XCTAssertEqual(actualToken.tokenString, token?.tokenString)
        
        
        XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
        
    }
    
    func testSave_firesNotification() {
        let identifier = "testIdentifier"
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTokenManagerNotifications), name: NSNotification.Name(rawValue: TokenManager.tokenManagerDidSaveTokenNotification), object: nil)
        
        XCTAssertTrue(TokenManager.save(accessToken: token!, tokenIdentifier:identifier))
        
        NotificationCenter.default.removeObserver(self)

        guard let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken else {
            XCTFail("Unable to fetch token")
            return
        }
        XCTAssertEqual(actualToken.tokenString, token?.tokenString)
        
        XCTAssertTrue(notificationFired)
        
        XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
        
    }
    
    func testGet() {
        
        let identifier = "testIdentifier"

        XCTAssertTrue(keychain!.setObject(token!, key: identifier))
        
        let actualToken = TokenManager.fetchToken(identifier: identifier)
        XCTAssertNotNil(actualToken)
        
        XCTAssertEqual(actualToken?.tokenString, token?.tokenString)
        
        XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
    }
    
    func testGet_nonExistent() {
        let identifer = "there.is.no.token.named.this.123412wfdasd3o"
        
        XCTAssertNil(TokenManager.fetchToken(identifier: identifer))
    }
    
    func testDelete() {
        let identifier = "testIdentifier"

        XCTAssertTrue(keychain!.setObject(token!, key: identifier))
        
        XCTAssertTrue(TokenManager.deleteToken(identifier: identifier))
        
        let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken
        guard actualToken == nil else {
            XCTFail("Token should have been deleted")
            XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
            return
        }
    }
    
    func testDelete_nonExistent() {
        let identifier = "there.is.no.token.named.this.123412wfdasd3o"
        
        XCTAssertFalse(TokenManager.deleteToken(identifier: identifier))
        
    }
    
    func testDelete_firesNotification() {
        
        let identifier = "testIdentifier"

        XCTAssertTrue(keychain!.setObject(token!, key: identifier))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTokenManagerNotifications), name: NSNotification.Name(rawValue: TokenManager.tokenManagerDidDeleteTokenNotification), object: nil)
        
        XCTAssertTrue(TokenManager.deleteToken(identifier: identifier))
        
        NotificationCenter.default.removeObserver(self)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTokenManagerNotifications), name: NSNotification.Name(rawValue: TokenManager.tokenManagerDidDeleteTokenNotification), object: nil)
        
        XCTAssertFalse(TokenManager.deleteToken(identifier: identifier))
        
        NotificationCenter.default.removeObserver(self)
        
        XCTAssertFalse(notificationFired)
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
        XCTAssertEqual(cookieStorage.cookies?.count, 2)
        XCTAssertEqual(cookieStorage.cookies(for: usUrl)?.count, 2)
        
        let identifier = "testIdentifier"

        _ = keychain?.setObject(token!, key: identifier)
        
        XCTAssertTrue(TokenManager.deleteToken(identifier: identifier))
        
        let actualToken = keychain?.getObjectForKey(identifier) as? AccessToken
        guard actualToken == nil else {
            XCTAssert(false)
            _ = keychain?.deleteObjectForKey(identifier)
            return
        }
        
        let testCookieStorage = HTTPCookieStorage.shared
        XCTAssertEqual(testCookieStorage.cookies?.count, 0)
        
    }
    
    
    //MARK: Helpers
            
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
    
    func handleTokenManagerNotifications() {
        notificationFired = true
    }
}
