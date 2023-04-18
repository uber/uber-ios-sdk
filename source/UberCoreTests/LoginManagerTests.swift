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
import OHHTTPStubs
import OHHTTPStubsSwift
import WebKit
@testable import UberCore

class LoginManagerTests: XCTestCase {
    private let timeout: Double = 2

    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
    }

    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }

    func testRidesAppDelegateContainsManager_afterNativeLogin() {
        let loginManager = LoginManager(loginType: .native)

        loginManager.login(requestedScopes: [.profile], presentingViewController: nil, completion: nil)

        XCTAssert(UberAppDelegate.shared.loginManager is LoginManager, "Expected RidesAppDelegate to have loginManager instance")
    }

    func testAuthentictorIsImplicit_whenLoginWithImplicitType() {
        let loginManager = LoginManager(loginType: .implicit)

        let presentingViewController = UIViewController()

        loginManager.login(requestedScopes: [.profile], presentingViewController: presentingViewController, completion: nil)

        XCTAssert(loginManager.authenticator is ImplicitGrantAuthenticator)
        XCTAssertTrue(loginManager.loggingIn)
    }

    func testAuthentictorIsAuthorizationCode_whenLoginWithAuthorizationCodeType() {
        let loginManager = LoginManager(loginType: .authorizationCode)

        let presentingViewController = UIViewController()

        loginManager.login(requestedScopes: [.profile], presentingViewController: presentingViewController, completion: nil)

        XCTAssert(loginManager.authenticator is AuthorizationCodeGrantAuthenticator)
        XCTAssertTrue(loginManager.loggingIn)
    }

    func testLoginFails_whenLoggingIn() {
        let expectation = self.expectation(description: "loginCompletion called")

        let loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { token, error in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.code, UberAuthenticationErrorType.unavailable.rawValue)
            expectation.fulfill()
        }

        let loginManagerMock = LoginManagerPartialMock()
        loginManagerMock.executeLoginClosure = { completionHandler in
            completionHandler?(nil, UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))
        }

        loginManagerMock.login(requestedScopes: [.profile], presentingViewController: nil, prefillValues: nil, completion: loginCompletion)

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

    func testOpenURLSuccess_rides() {
        let loginManager = LoginManager(loginType: .native, productFlowPriority: [UberAuthenticationProductFlow(.rides)])
        let testApp = UIApplication.shared
        guard let testURL = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "com.ubercab.foo"
        let testAnnotation = "annotation"

        let authenticatorMock = RidesNativeAuthenticatorPartialStub(scopes: [.profile])
        authenticatorMock.consumeResponseCompletionValue = (nil, nil)
        loginManager.authenticator = authenticatorMock
        loginManager.loggingIn = true

        XCTAssertTrue(loginManager.application(testApp, open: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))

        XCTAssertFalse(loginManager.loggingIn)
        XCTAssertNil(loginManager.authenticator)
    }

    func testOpenURLSuccess_eats() {
        let loginManager = LoginManager(loginType: .native, productFlowPriority: [UberAuthenticationProductFlow(.eats)])
        let testApp = UIApplication.shared
        guard let testURL = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "com.ubercab.UberEats"
        let testAnnotation = "annotation"

        let authenticatorMock = EatsNativeAuthenticatorPartialStub(scopes: [.profile])
        authenticatorMock.consumeResponseCompletionValue = (nil, nil)
        loginManager.authenticator = authenticatorMock
        loginManager.loggingIn = true

        XCTAssertTrue(loginManager.application(testApp, open: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))

        XCTAssertFalse(loginManager.loggingIn)
        XCTAssertNil(loginManager.authenticator)
    }

    func testCancelLoginNotCalled_whenNotEnteringForeground() {
        let loginManager = LoginManager(loginType: .native)
        loginManager.loggingIn = true

        loginManager.applicationDidBecomeActive()

        XCTAssertNil(loginManager.authenticator)
        XCTAssertTrue(loginManager.loggingIn)
    }

    func testCancelLoginCalled_whenDidBecomeActive() {
        let loginManager = LoginManager(loginType: .native)
        loginManager.loggingIn = true

        loginManager.applicationWillEnterForeground()
        loginManager.applicationDidBecomeActive()

        XCTAssertNil(loginManager.authenticator)
        XCTAssertFalse(loginManager.loggingIn)
    }

    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withConfiguration_alwaysUseAuthCodeFallback() {
        Configuration.shared.alwaysUseAuthCodeFallback = true
        let scopes = [UberScope.historyLite]

        let loginManager = LoginManager(loginType: .native)

        let nativeAuthenticatorStub = RidesNativeAuthenticatorPartialStub(scopes: [])
        nativeAuthenticatorStub.consumeResponseCompletionValue = (nil, UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))

        loginManager.authenticator = nativeAuthenticatorStub

        let viewController = UIViewController()

        loginManager.login(requestedScopes: scopes, presentingViewController: viewController, completion: nil)

        XCTAssertEqual(loginManager.loginType, LoginType.authorizationCode)
    }

    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withPrivelegedScopes_rides() {
        Configuration.shared.useFallback = true
        let scopes = [UberScope.request]

        let loginManager = LoginManager(loginType: .native, productFlowPriority: [UberAuthenticationProductFlow(.rides)])

        let nativeAuthenticatorStub = RidesNativeAuthenticatorPartialStub(scopes: [])
        nativeAuthenticatorStub.consumeResponseCompletionValue = (nil, UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))

        loginManager.authenticator = nativeAuthenticatorStub

        let viewController = UIViewController()

        loginManager.login(requestedScopes: scopes, presentingViewController: viewController, completion: nil)

        XCTAssertEqual(loginManager.loginType, LoginType.authorizationCode)
    }

    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withPrivelegedScopes_eats() {
        Configuration.shared.useFallback = true
        let scopes = [UberScope.request]

        let loginManager = LoginManager(loginType: .native, productFlowPriority: [UberAuthenticationProductFlow(.eats)])

        let nativeAuthenticatorStub = EatsNativeAuthenticatorPartialStub(scopes: [])
        nativeAuthenticatorStub.consumeResponseCompletionValue = (nil, UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))

        loginManager.authenticator = nativeAuthenticatorStub

        let viewController = UIViewController()

        loginManager.login(requestedScopes: scopes, presentingViewController: viewController, completion: nil)

        XCTAssertEqual(loginManager.loginType, LoginType.authorizationCode)
    }

    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withGeneralScopes_rides() {
        let scopes = [UberScope.profile]

        let loginManager = LoginManager(loginType: .native, productFlowPriority: [UberAuthenticationProductFlow(.rides)])

        let nativeAuthenticatorStub = RidesNativeAuthenticatorPartialStub(scopes: [])
        nativeAuthenticatorStub.consumeResponseCompletionValue = (nil, UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))

        loginManager.authenticator = nativeAuthenticatorStub

        let viewController = UIViewController()

        loginManager.login(requestedScopes: scopes, presentingViewController: viewController, completion: nil)

        XCTAssertEqual(loginManager.loginType, LoginType.implicit)
    }

    func testNativeLoginCompletionDoesFallback_whenUnavailableError_withGeneralScopes_eats() {
        let scopes = [UberScope.profile]

        let loginManager = LoginManager(loginType: .native, productFlowPriority: [UberAuthenticationProductFlow(.eats)])

        let nativeAuthenticatorStub = EatsNativeAuthenticatorPartialStub(scopes: [])
        nativeAuthenticatorStub.consumeResponseCompletionValue = (nil, UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))

        loginManager.authenticator = nativeAuthenticatorStub

        let viewController = UIViewController()

        loginManager.login(requestedScopes: scopes, presentingViewController: viewController, completion: nil)

        XCTAssertEqual(loginManager.loginType, LoginType.implicit)
    }
    
    func testImplicitLogin_executesParRequest() {
        
        let expectation = expectation(description: "Implicit login PAR endpoint called")

        stub(condition: isPath("/oauth/v2/par")) { _ in
            expectation.fulfill()
            return HTTPStubsResponse()
        }
        
        let loginManager = LoginManager(
            loginType: .implicit,
            productFlowPriority: [UberAuthenticationProductFlow(.eats)]
        )
        
        loginManager.login(
            requestedScopes: [UberScope.profile],
            presentingViewController: UIViewController(),
            prefillValues: Prefill(email: "test@test.com"),
            completion: nil
        )

        waitForExpectations(timeout: 0.2, handler: nil)
    }
        
    func testAuthorizationCodeLogin_executesParRequest() {
        
        let expectation = expectation(description: "Authorization code login PAR endpoint called")

        stub(condition: isPath("/oauth/v2/par")) { _ in
            expectation.fulfill()
            return HTTPStubsResponse()
        }
        
        let loginManager = LoginManager(
            loginType: .authorizationCode,
            productFlowPriority: [UberAuthenticationProductFlow(.eats)]
        )
        
        loginManager.login(
            requestedScopes: [UberScope.profile],
            presentingViewController: UIViewController(),
            prefillValues: Prefill(email: "test@test.com"),
            completion: nil
        )

        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testLogin_withNoPrefillValues_doesNotExecutesParRequest() {
        
        let expectation = expectation(description: "No prefill login PAR endpoint not called")
        expectation.isInverted = true

        stub(condition: isPath("/oauth/v2/par")) { _ in
            expectation.fulfill()
            return HTTPStubsResponse()
        }
        
        let loginManager = LoginManager(
            loginType: .authorizationCode,
            productFlowPriority: [UberAuthenticationProductFlow(.eats)]
        )
        
        loginManager.login(
            requestedScopes: [UberScope.profile],
            presentingViewController: UIViewController(),
            prefillValues: nil,
            completion: nil
        )

        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testLogin_withEmptyPrefillValues_doesNotExecutesParRequest() {
        
        let expectation = expectation(description: "EmptyPrefill login PAR endpoint not called")
        expectation.isInverted = true

        stub(condition: isPath("/oauth/v2/par")) { _ in
            expectation.fulfill()
            return HTTPStubsResponse()
        }
        
        let loginManager = LoginManager(
            loginType: .authorizationCode,
            productFlowPriority: [UberAuthenticationProductFlow(.eats)]
        )
        
        loginManager.login(
            requestedScopes: [UberScope.profile],
            presentingViewController: UIViewController(),
            prefillValues: Prefill(),
            completion: nil
        )

        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testNativeLogin_doesNotExecuteParRequest() {
        
        let expectation = expectation(description: "Native login PAR endpoint not called")
        expectation.isInverted = true

        stub(condition: isPath("/oauth/v2/par")) { _ in
            expectation.fulfill()
            return HTTPStubsResponse()
        }
        
        let loginManager = LoginManager(
            loginType: .native,
            productFlowPriority: [UberAuthenticationProductFlow(.eats)]
        )
        
        loginManager.login(
            requestedScopes: [UberScope.profile],
            presentingViewController: UIViewController(),
            prefillValues: Prefill(),
            completion: nil
        )

        waitForExpectations(timeout: 0.2, handler: nil)
    }
}

