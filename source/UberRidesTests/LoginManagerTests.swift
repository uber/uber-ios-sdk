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
    
    func testAuthentictorIsNative_whenLoginWithNativeType() {
        let expectation = expectationWithDescription("executeLogin called")
        
        let executeLoginClosure: () -> () = {
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Native)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: nil, completion: nil)
        guard let authenticator = loginManagerMock.authenticator as? NativeAuthenticator else {
            XCTFail("Expected NativeAuthenticator")
            return
        }
        XCTAssertEqual(authenticator.callbackURIType, CallbackURIType.Native)
        XCTAssertTrue(loginManagerMock.loggingIn)
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testRidesAppDelegateContainsManager_afterNativeLogin() {
        let executeLoginClosure: () -> () = {}
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Native)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: nil, completion: nil)
        guard let authenticator = loginManagerMock.authenticator as? NativeAuthenticator else {
            XCTFail("Expected NativeAuthenticator")
            return
        }
        
        authenticator.deeplinkCompletion?(nil)
        guard let ridesAppDelegateLoginManager = RidesAppDelegate.sharedInstance.loginManager as? LoginManagerPartialMock else {
            XCTFail("Expected RidesAppDelegate to have loginManager instance")
            return
        }
        XCTAssertEqual(ridesAppDelegateLoginManager, loginManagerMock)
    }
    
    func testAuthentictorIsImplicit_whenLoginWithImplicitType() {
        let expectation = expectationWithDescription("executeLogin called")
        
        let executeLoginClosure: () -> () = {
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Implicit)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        let presentingViewController = UIViewController()
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: presentingViewController, completion: nil)
        guard let authenticator = loginManagerMock.authenticator as? ImplicitGrantAuthenticator else {
            XCTFail("Expected ImplicitGrantAuthenticator")
            return
        }

        XCTAssertEqual(authenticator.callbackURIType, CallbackURIType.Implicit)
        XCTAssertTrue(loginManagerMock.loggingIn)
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testAuthentictorIsAuthorizationCode_whenLoginWithAuthorizationCodeType() {
        let expectation = expectationWithDescription("executeLogin called")
        
        let executeLoginClosure: () -> () = {
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .AuthorizationCode)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        let presentingViewController = UIViewController()
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: presentingViewController, completion: nil)
        guard let authenticator = loginManagerMock.authenticator as? AuthorizationCodeGrantAuthenticator else {
            XCTFail("Expected AuthorizationCodeGrantAuthenticator")
            return
        }
        
        XCTAssertEqual(authenticator.callbackURIType, CallbackURIType.AuthorizationCode)
        XCTAssertTrue(loginManagerMock.loggingIn)
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testLoginFails_whenLoggingIn() {
        let expectation = expectationWithDescription("loginCompletion called")
        
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.Unavailable.rawValue)
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Implicit)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        loginManagerMock.loggingIn = true
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: nil, completion: loginCompletion)
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testLoginFails_whenLoginWithAuthorizationCodeType_whenNoPresentingViewController() {
        let expectation = expectationWithDescription("loginCompletion called")
        
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.UnableToPresentLogin.rawValue)
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .AuthorizationCode)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: nil, completion: loginCompletion)
        
        XCTAssertNil(loginManagerMock.authenticator)
        XCTAssertFalse(loginManagerMock.loggingIn)
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testLoginFails_whenLoginWithImplicitType_whenNoPresentingViewController() {
        let expectation = expectationWithDescription("loginCompletion called")
        
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.UnableToPresentLogin.rawValue)
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Implicit)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: nil, completion: loginCompletion)
        
        XCTAssertNil(loginManagerMock.authenticator)
        XCTAssertFalse(loginManagerMock.loggingIn)
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testOpenURLFails_whenInvalidSource() {
        let loginManager = LoginManager(loginType: .Native)
        let testApp = UIApplication.sharedApplication()
        guard let testURL = NSURL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "com.not.uber.app"
        let testAnnotation = "annotation"
        
        XCTAssertFalse(loginManager.application(testApp, openURL: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))
    }
    
    func testOpenURLFails_whenNotNativeType() {
        let loginManager = LoginManager(loginType: .Implicit)
        let testApp = UIApplication.sharedApplication()
        guard let testURL = NSURL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "com.ubercab.foo"
        let testAnnotation = "annotation"
        
        XCTAssertFalse(loginManager.application(testApp, openURL: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))
    }
    
    func testOpenURLSuccess() {
        let expectation = expectationWithDescription("handleRedirect called")
        let loginManager = LoginManager(loginType: .Native)
        let testApp = UIApplication.sharedApplication()
        guard let testURL = NSURL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "com.ubercab.foo"
        let testAnnotation = "annotation"
        
        let handleRedirectClosure: ((NSURLRequest) -> (Bool)) = { urlRequest in
            guard let url = urlRequest.URL else {
                XCTFail("Redirect URL was nil")
                return false
            }
            XCTAssertEqual(url, testURL)
            expectation.fulfill()
            return true
        }
        
        let authenticatorMock = NativeAuthenticatorPartialMock(scopes: [.Profile])
        authenticatorMock.handleRedirectClosure = handleRedirectClosure
        loginManager.authenticator = authenticatorMock
        
        XCTAssertTrue(loginManager.application(testApp, openURL: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))
        
        waitForExpectationsWithTimeout(0.2) { _ in
            XCTAssertFalse(loginManager.loggingIn)
            XCTAssertNil(loginManager.authenticator)
        }
    }
    
    func testCancelLoginCalled_whenDidBecomeActive() {
        let expectation = expectationWithDescription("loginCompletion called")
        
        let loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.UserCancelled.rawValue)
            expectation.fulfill()
        }
        
        let loginManager = LoginManager(loginType: .Native)
        loginManager.loggingIn = true
        
        let nativeAuthenticatorMock = NativeAuthenticatorPartialMock(scopes: [.Profile])
        nativeAuthenticatorMock.loginCompletion = loginCompletion
        loginManager.authenticator = nativeAuthenticatorMock
        loginManager.applicationDidBecomeActive()
        
        XCTAssertNil(loginManager.authenticator)
        XCTAssertFalse(loginManager.loggingIn)
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testNativeLoginCompletion_whenNotUnavailableError() {
        let expectation = expectationWithDescription("loginCompletion called")
        
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.InvalidRequest.rawValue)
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Native)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: nil, completion: loginCompletion)
        
        loginManagerMock.authenticator?.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .InvalidRequest))
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withPrivelegedScopes() {
        let expectationNative = expectationWithDescription("executeLogin Native called")
        let expectationAuthorizationCode = expectationWithDescription("executeLogin Authorization Code called")
        
        Configuration.setFallbackEnabled(true)
        let scopes = [RidesScope.Request]
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Native)
        
        let executeLoginClosureAuthorizationCode: () -> () = {
            expectationAuthorizationCode.fulfill()
        }
        
        let executeLoginClosureNative: () -> () = {
            expectationNative.fulfill()
            loginManagerMock.executeLoginClosure = executeLoginClosureAuthorizationCode
        }
        
        loginManagerMock.executeLoginClosure = executeLoginClosureNative
        
        let viewController = UIViewController()
        
        loginManagerMock.login(requestedScopes: scopes, presentingViewController: viewController, completion: nil)
        
        loginManagerMock.authenticator?.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .Unavailable))
        
        waitForExpectationsWithTimeout(0.2) { _ in
            XCTAssertEqual(loginManagerMock.loginType, LoginType.AuthorizationCode)
        }
    }
    
    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withGeneralScopes() {
        let expectationNative = expectationWithDescription("executeLogin Native called")
        let expectationAuthorizationCode = expectationWithDescription("executeLogin Authorization Code called")
        
        let scopes = [RidesScope.Profile]
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Native)
        
        let executeLoginClosureAuthorizationCode: () -> () = {
            expectationAuthorizationCode.fulfill()
        }
        
        let executeLoginClosureNative: () -> () = {
            expectationNative.fulfill()
            loginManagerMock.executeLoginClosure = executeLoginClosureAuthorizationCode
        }
        
        loginManagerMock.executeLoginClosure = executeLoginClosureNative
        
        let viewController = UIViewController()
        
        loginManagerMock.login(requestedScopes: scopes, presentingViewController: viewController, completion: nil)
        
        loginManagerMock.authenticator?.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .Unavailable))
        
        waitForExpectationsWithTimeout(0.2) { _ in
            XCTAssertEqual(loginManagerMock.loginType, LoginType.Implicit)
        }
    }
    
    func testImplicitLoginCompletion_withPresentingViewController() {
        class UIViewControllerMock : UIViewController {
            
            var dismissClosure: (() -> ())?
            
            override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
                dismissClosure?()
                completion?()
            }
        }
        
        let expectation = expectationWithDescription("loginCompletion called")
        let dismissExpectation = expectationWithDescription("dissmissViewController called")
        let viewController = UIViewControllerMock()
    
        let dismissClosure: () -> () = {
            dismissExpectation.fulfill()
        }
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.InvalidRequest.rawValue)
            expectation.fulfill()
        }
        
        viewController.dismissClosure = dismissClosure
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .Implicit)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        
        loginManagerMock.login(requestedScopes: [.Profile], presentingViewController: viewController, completion: loginCompletion)
        
        loginManagerMock.authenticator?.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .InvalidRequest))
        
        XCTAssertFalse(loginManagerMock.loggingIn)
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
}
