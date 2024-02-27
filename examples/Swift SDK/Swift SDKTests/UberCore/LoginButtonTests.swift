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
@testable import UberCore

class LoginButtonTests : XCTestCase {
    
    private var keychain: KeychainWrapper!
    private var testToken: AccessToken!
    private var testDataSource: TestDataSource!

    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        keychain = KeychainWrapper()
        testToken = AccessToken(tokenString: "testTokenString")
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        keychain = nil
        super.tearDown()
    }
    
    func testButtonState_whenSignedOut() {
        let identifier = "testIdentifier"

        _ = keychain.deleteObjectForKey(identifier)
        
        let token = TokenManager.fetchToken(identifier: identifier)
        XCTAssertNil(token)
        
        let loginManager = LoginManager(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .implicit)
        let loginButton = LoginButton(frame: CGRect.zero, scopes: [], loginManager: loginManager)
        
        XCTAssertEqual(loginButton.buttonState, LoginButtonState.signedOut)
        
        _ = keychain.deleteObjectForKey(identifier)
    }
    
    func testLabelText_whenSignedIn() {
        let identifier = "testIdentifier"
        
        let token: AccessToken = testToken

        XCTAssertTrue(keychain.setObject(token, key: identifier))
        
        let loginManager = LoginManager(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .implicit)
        let loginButton = LoginButton(frame: CGRect.zero, scopes: [], loginManager: loginManager)
        
        XCTAssertEqual(loginButton.buttonState, LoginButtonState.signedIn)
        
        XCTAssertTrue(keychain.deleteObjectForKey(identifier))
    }
    
    func testLoginCalled_whenSignedOut() {
        let identifier = "testIdentifier"

        _ = keychain.deleteObjectForKey(identifier)
        
        let token = TokenManager.fetchToken(identifier: identifier)
        XCTAssertNil(token)
        
        let expectation = self.expectation(description: "Expected executeLogin() called")
        
        let loginManager = LoginManagerPartialMock(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .implicit)
        loginManager.executeLoginClosure = { _ in
            expectation.fulfill()
        }
        let loginButton = LoginButton(frame: CGRect.zero, scopes: [.profile], loginManager: loginManager)
        
        loginButton.presentingViewController = UIViewController()
        XCTAssertNotNil(loginButton)
        XCTAssertEqual(loginButton.buttonState, LoginButtonState.signedOut)
        loginButton.uberButtonTapped(loginButton)
        
        waitForExpectations(timeout: 0.2) { _ in
            _ = self.keychain.deleteObjectForKey(identifier)
        }
    }
    
    func testLogOut_whenSignedIn() {
        let identifier = "testIdentifier"

        _ = keychain.deleteObjectForKey(identifier)
        
        let token: AccessToken = testToken

        XCTAssertTrue(keychain.setObject(token, key: identifier))
        
        let loginManager = LoginManager(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .implicit)
        let loginButton = LoginButton(frame: CGRect.zero, scopes: [.profile], loginManager: loginManager)
        
        loginButton.presentingViewController = UIViewController()
        XCTAssertNotNil(loginButton)
        XCTAssertEqual(loginButton.buttonState, LoginButtonState.signedIn)
        loginButton.uberButtonTapped(loginButton)
        
        XCTAssertNil(TokenManager.fetchToken(identifier: identifier))
        
        _ = keychain.deleteObjectForKey(identifier)
    }
    
    func test_loginButton_callsDataSourceOnTap() {
        let identifier = "testIdentifier"
        
        let loginManager = LoginManager(accessTokenIdentifier: identifier, keychainAccessGroup: nil, loginType: .implicit)
        let loginButton = LoginButton(frame: CGRect.zero, scopes: [.profile], loginManager: loginManager)
        
        let expectation = self.expectation(description: "Prefill handler called")
        
        let prefillHandler: () -> Prefill? = {
            expectation.fulfill()
            return nil
        }
        
        testDataSource = TestDataSource(prefillHandler)
        loginButton.dataSource = testDataSource
        loginButton.uberButtonTapped(loginButton)
        
        waitForExpectations(timeout: 0.2)
    }
    
    // MARK: - TestDataSource
    
    fileprivate class TestDataSource: LoginButtonDataSource {
        
        private let prefillValueHandler: () -> Prefill?
        
        init(_ prefillValueHandler: @escaping () -> Prefill?) {
            self.prefillValueHandler = prefillValueHandler
        }
        
        func prefillValues(_ button: LoginButton) -> Prefill? {
            prefillValueHandler()
        }
    }
}
