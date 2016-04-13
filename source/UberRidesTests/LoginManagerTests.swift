//
//  LoginManagerTests.swift
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
import WebKit
@testable import UberRides

class LoginManagerTests: XCTestCase {
    private let timeout: Double = 2
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setSandboxEnabled(true)
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testPresentNetworkErrorAlert_cancelsLoad_presentsAlertView() {
        let expectation = expectationWithDescription("Test presentNetworkAlert() call")
        let loginLoadExpecation = expectationWithDescription("LoginView cancelLoad() call")
        
        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation.fulfill()
            XCTAssertTrue(viewController.dynamicType == UIAlertController.self)
        }
        
        let loginClosure: () -> () = {
            loginLoadExpecation.fulfill()
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier)

        let loginViewMock = LoginViewMock(scopes: [], testClosure: loginClosure)
        let oauthViewControllerMock = OAuthViewControllerMock(loginView: loginViewMock, presentViewControllerClosure: presentViewControllerClosure)
        
        oauthViewControllerMock.loginView = loginViewMock
        
        loginManager.oauthViewController = oauthViewControllerMock
        
        loginManager.loginView(oauthViewControllerMock.loginView, didFailWithError: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .NetworkError))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
}
