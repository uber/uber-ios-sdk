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
        Configuration.bundle = Bundle(for: type(of: self))
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testAuthentictorIsNative_whenLoginWithNativeType() {
        let expectation = self.expectation(description: "executeLogin called")
        
        let executeLoginClosure: () -> () = {
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .native)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: nil, completion: nil)
        guard let authenticator = loginManagerMock.authenticator as? NativeAuthenticator else {
            XCTFail("Expected NativeAuthenticator")
            return
        }
        XCTAssertEqual(authenticator.callbackURIType, CallbackURIType.native)
        XCTAssertTrue(loginManagerMock.loggingIn)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testRidesAppDelegateContainsManager_afterNativeLogin() {
        let executeLoginClosure: () -> () = {}
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .native)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: nil, completion: nil)
        guard let authenticator = loginManagerMock.authenticator as? NativeAuthenticator else {
            XCTFail("Expected NativeAuthenticator")
            return
        }
        
        authenticator.deeplinkCompletion?(nil)
        guard let ridesAppDelegateLoginManager = RidesAppDelegate.shared.loginManager as? LoginManagerPartialMock else {
            XCTFail("Expected RidesAppDelegate to have loginManager instance")
            return
        }
        XCTAssertEqual(ridesAppDelegateLoginManager, loginManagerMock)
    }
    
    func testAuthentictorIsImplicit_whenLoginWithImplicitType() {
        let expectation = self.expectation(description: "executeLogin called")
        
        let executeLoginClosure: () -> () = {
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .implicit)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        let presentingViewController = UIViewController()
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: presentingViewController, completion: nil)
        guard let authenticator = loginManagerMock.authenticator as? ImplicitGrantAuthenticator else {
            XCTFail("Expected ImplicitGrantAuthenticator")
            return
        }

        XCTAssertEqual(authenticator.callbackURIType, CallbackURIType.implicit)
        XCTAssertTrue(loginManagerMock.loggingIn)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testAuthentictorIsAuthorizationCode_whenLoginWithAuthorizationCodeType() {
        let expectation = self.expectation(description: "executeLogin called")
        
        let executeLoginClosure: () -> () = {
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .authorizationCode)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        let presentingViewController = UIViewController()
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: presentingViewController, completion: nil)
        guard let authenticator = loginManagerMock.authenticator as? AuthorizationCodeGrantAuthenticator else {
            XCTFail("Expected AuthorizationCodeGrantAuthenticator")
            return
        }
        
        XCTAssertEqual(authenticator.callbackURIType, CallbackURIType.authorizationCode)
        XCTAssertTrue(loginManagerMock.loggingIn)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testLoginFails_whenLoggingIn() {
        let expectation = self.expectation(description: "loginCompletion called")
        
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.unavailable.rawValue)
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .implicit)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        loginManagerMock.loggingIn = true
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: nil, completion: loginCompletion)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testLoginFails_whenLoginWithAuthorizationCodeType_whenNoPresentingViewController() {
        let expectation = self.expectation(description: "loginCompletion called")
        
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.unableToPresentLogin.rawValue)
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .authorizationCode)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: nil, completion: loginCompletion)
        
        XCTAssertNil(loginManagerMock.authenticator)
        XCTAssertFalse(loginManagerMock.loggingIn)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testLoginFails_whenLoginWithImplicitType_whenNoPresentingViewController() {
        let expectation = self.expectation(description: "loginCompletion called")
        
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.unableToPresentLogin.rawValue)
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .implicit)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: nil, completion: loginCompletion)
        
        XCTAssertNil(loginManagerMock.authenticator)
        XCTAssertFalse(loginManagerMock.loggingIn)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testOpenURLFails_whenInvalidSource() {
        let loginManager = LoginManager(loginType: .native)
        let testApp = UIApplication.shared
        guard let testURL = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "com.not.uber.app"
        let testAnnotation = "annotation"
        
        XCTAssertFalse(loginManager.application(testApp, open: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))
    }
    
    func testOpenURLFails_whenNotNativeType() {
        let loginManager = LoginManager(loginType: .implicit)
        let testApp = UIApplication.shared
        guard let testURL = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "com.ubercab.foo"
        let testAnnotation = "annotation"
        
        XCTAssertFalse(loginManager.application(testApp, open: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))
    }
    
    func testOpenURLSuccess() {
        let expectation = self.expectation(description: "handleRedirect called")
        let loginManager = LoginManager(loginType: .native)
        let testApp = UIApplication.shared
        guard let testURL = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "com.ubercab.foo"
        let testAnnotation = "annotation"
        
        let handleRedirectClosure: ((URLRequest) -> (Bool)) = { urlRequest in
            guard let url = urlRequest.url else {
                XCTFail("Redirect URL was nil")
                return false
            }
            XCTAssertEqual(url, testURL)
            expectation.fulfill()
            return true
        }
        
        let authenticatorMock = NativeAuthenticatorPartialMock(scopes: [.profile])
        authenticatorMock.handleRedirectClosure = handleRedirectClosure
        loginManager.authenticator = authenticatorMock
        
        XCTAssertTrue(loginManager.application(testApp, open: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))
        
        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertFalse(loginManager.loggingIn)
            XCTAssertNil(loginManager.authenticator)
        }
    }
    
    func testCancelLoginCalled_whenDidBecomeActive() {
        let expectation = self.expectation(description: "loginCompletion called")
        
        let loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.userCancelled.rawValue)
            expectation.fulfill()
        }
        
        let loginManager = LoginManager(loginType: .native)
        loginManager.loggingIn = true
        
        let nativeAuthenticatorMock = NativeAuthenticatorPartialMock(scopes: [.profile])
        nativeAuthenticatorMock.loginCompletion = loginCompletion
        loginManager.authenticator = nativeAuthenticatorMock
        loginManager.applicationDidBecomeActive()
        
        XCTAssertNil(loginManager.authenticator)
        XCTAssertFalse(loginManager.loggingIn)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testNativeLoginCompletion_whenNotUnavailableError() {
        let expectation = self.expectation(description: "loginCompletion called")
        
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.invalidRequest.rawValue)
            expectation.fulfill()
        }
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .native)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: nil, completion: loginCompletion)
        
        loginManagerMock.authenticator?.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest))
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withPrivelegedScopes() {
        let expectationNative = expectation(description: "executeLogin Native called")
        let expectationAuthorizationCode = expectation(description: "executeLogin Authorization Code called")
        
        Configuration.shared.useFallback = true
        let scopes = [RidesScope.request]
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .native)
        
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
        
        loginManagerMock.authenticator?.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))
        
        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(loginManagerMock.loginType, LoginType.authorizationCode)
        }
    }
    
    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withGeneralScopes() {
        let expectationNative = expectation(description: "executeLogin Native called")
        let expectationAuthorizationCode = expectation(description: "executeLogin Authorization Code called")
        
        let scopes = [RidesScope.profile]
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .native)
        
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
        
        loginManagerMock.authenticator?.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))
        
        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(loginManagerMock.loginType, LoginType.implicit)
        }
    }
    
    func testImplicitLoginCompletion_withPresentingViewController() {
        class UIViewControllerMock : UIViewController {
            
            var dismissClosure: (() -> ())?
            
            override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
                dismissClosure?()
                completion?()
            }
        }
        
        let expectation = self.expectation(description: "loginCompletion called")
        let dismissExpectation = self.expectation(description: "dissmissViewController called")
        let viewController = UIViewControllerMock()
    
        let dismissClosure: () -> () = {
            dismissExpectation.fulfill()
        }
        let executeLoginClosure: () -> () = {}
        let loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.invalidRequest.rawValue)
            expectation.fulfill()
        }
        
        viewController.dismissClosure = dismissClosure
        
        let loginManagerMock = LoginManagerPartialMock(loginType: .implicit)
        loginManagerMock.executeLoginClosure = executeLoginClosure
        
        
        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: viewController, completion: loginCompletion)
        
        loginManagerMock.authenticator?.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest))
        
        XCTAssertFalse(loginManagerMock.loggingIn)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}
