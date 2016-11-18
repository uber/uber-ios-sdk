//
//  LoginButtonTests.swift
//  UberRides
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
import CoreLocation
@testable import UberRides

class LoginButtonTests : XCTestCase {
    
    private var keychain: KeychainWrapper?
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setSandboxEnabled(true)
        keychain = KeychainWrapper()
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        keychain = nil
        super.tearDown()
    }
    
    func testButtonState_whenSignedOut() {
        let identifier = "testIdentifier"

        keychain!.deleteObjectForKey(identifier)
        
        let token = TokenManager.fetchToken(identifier)
        XCTAssertNil(token)
        
        let loginManager = LoginManager(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .Implicit)
        let loginButton = LoginButton(frame: CGRectZero, scopes: [], loginManager: loginManager)
        
        XCTAssertEqual(loginButton.buttonState, LoginButtonState.SignedOut)
        
        keychain!.deleteObjectForKey(identifier)
    }
    
    func testLabelText_whenSignedIn() {
        let identifier = "testIdentifier"
        
        let token = getTestToken()

        XCTAssertTrue(keychain!.setObject(token, key: identifier))
        
        let loginManager = LoginManager(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .Implicit)
        let loginButton = LoginButton(frame: CGRectZero, scopes: [], loginManager: loginManager)
        
        XCTAssertEqual(loginButton.buttonState, LoginButtonState.SignedIn)
        
        XCTAssertTrue(keychain!.deleteObjectForKey(identifier))
    }
    
    func testLoginCalled_whenSignedOut() {
        let identifier = "testIdentifier"

        keychain!.deleteObjectForKey(identifier)
        
        let token = TokenManager.fetchToken(identifier)
        XCTAssertNil(token)
        
        let expectation = expectationWithDescription("Expected executeLogin() called")
        
        let loginManager = LoginManagerPartialMock(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .Implicit)
        loginManager.executeLoginClosure = {
            expectation.fulfill()
        }
        let loginButton = LoginButton(frame: CGRectZero, scopes: [.Profile], loginManager: loginManager)
        
        loginButton.presentingViewController = UIViewController()
        XCTAssertNotNil(loginButton)
        XCTAssertEqual(loginButton.buttonState, LoginButtonState.SignedOut)
        loginButton.uberButtonTapped(loginButton)
        
        waitForExpectationsWithTimeout(0.2) { _ in
            self.keychain!.deleteObjectForKey(identifier)
        }
    }
    
    func testLogOut_whenSignedIn() {
        let identifier = "testIdentifier"

        keychain!.deleteObjectForKey(identifier)
        
        let token = getTestToken()

        XCTAssertTrue(keychain!.setObject(token, key: identifier))
        
        let loginManager = LoginManager(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .Implicit)
        let loginButton = LoginButton(frame: CGRectZero, scopes: [.Profile], loginManager: loginManager)
        
        loginButton.presentingViewController = UIViewController()
        XCTAssertNotNil(loginButton)
        XCTAssertEqual(loginButton.buttonState, LoginButtonState.SignedIn)
        loginButton.uberButtonTapped(loginButton)
        
        XCTAssertNil(TokenManager.fetchToken(identifier))
        
        keychain!.deleteObjectForKey(identifier)
    }
    
    //Mark: Helpers
    
    func getTestToken() -> AccessToken! {
        let tokenData = ["access_token" : "testTokenString"]
        return AccessToken(JSON: tokenData)
    }
}
