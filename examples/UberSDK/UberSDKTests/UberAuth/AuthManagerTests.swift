//
//  AuthManagerTests.swift
//  UberSDKTests
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
import UberCore
@testable import UberAuth

final class UberAuthTests: XCTestCase {

    let uberAuth = UberAuth()
    
    func test_login_triggersAuthProviderExecution() {
        
        let authProvider = AuthProvidingMock()
        authProvider.executeHandler = { _, _, completion in
            completion(.success(.init()))
        }
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: nil
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 0)
        
        uberAuth.login(
            context: context,
            completion: { _ in }
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 1)
    }
    
    func test_staticLogin_triggersAuthProviderExecution() {
        
        let authProvider = AuthProvidingMock()
        authProvider.executeHandler = { _, _, completion in
            completion(.success(.init()))
        }
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: nil
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 0)
        
        UberAuth.login(
            context: context,
            completion: { _ in }
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 1)
    }
    
    func test_loginSuccess_callsCompletionWithResult() {
        
        let client: Client = .init()
        let authProvider = AuthProvidingMock()
        authProvider.executeHandler = { _, _, completion in
            completion(.success(.init()))
        }
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: nil
        )
        
        var completionCalled = false
        let completion: AuthCompletion = { result in
            completionCalled = true
            switch result {
            case .success(let resultClient):
                XCTAssertEqual(client, resultClient)
            case .failure:
                XCTFail()
            }
        }
        
        XCTAssertEqual(authProvider.executeCallCount, 0)
        
        uberAuth.login(
            context: context,
            completion: completion
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 1)
        XCTAssertTrue(completionCalled)
    }
    
    func test_loginFailure_callsCompletionWithResult() {
        
        let authProvider = AuthProvidingMock()
        authProvider.executeHandler = { _, _, completion in
            completion(.failure(UberAuthError.serviceError))
        }
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: nil
        )
        
        var completionCalled = false
        let completion: AuthCompletion = { result in
            completionCalled = true
            switch result {
            case .success:
                XCTFail()
            case .failure:
                break
            }
        }
        
        XCTAssertEqual(authProvider.executeCallCount, 0)
        
        uberAuth.login(
            context: context,
            completion: completion
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 1)
        XCTAssertTrue(completionCalled)
    }

    func test_login_prefillPassedToAuthProvider() {
        
        let prefill = Prefill()
        let authProvider = AuthProvidingMock()
        authProvider.executeHandler = { _, authPrefill, completion in
            XCTAssertEqual(authPrefill, prefill)
            completion(.failure(UberAuthError.serviceError))
        }
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: prefill
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 0)
        
        uberAuth.login(
            context: context,
            completion: { _ in }
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 1)
    }
    
    func test_handleUrl_callsSameAuthProvider() {
        let authProvider = AuthProvidingMock()
        let url = URL(string: "https://uber.com")!
        
        authProvider.handleHandler = { authURL -> Bool in
            XCTAssertEqual(url, authURL)
            return true
        }
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: nil
        )
        
        XCTAssertEqual(authProvider.executeCallCount, 0)
        XCTAssertEqual(authProvider.handleCallCount, 0)
        
        uberAuth.login(
            context: context,
            completion: { _ in }
        )
                
        let handled = uberAuth.handle(url)
        
        XCTAssertTrue(handled)
        XCTAssertEqual(authProvider.handleCallCount, 1)
        XCTAssertEqual(authProvider.executeCallCount, 1)
    }

    func test_handleUrl_notTriggeredIfNoAuthContext() {
        
        let authProvider = AuthProvidingMock()

        XCTAssertEqual(authProvider.handleCallCount, 0)
        
        UberAuth.handle(
            URL(string: "https://auth.uber.com/v2")!
        )
        
        XCTAssertEqual(authProvider.handleCallCount, 0)
    }

    
    func test_staticHandleUrl_triggersAuthProviderExecution() {
        
        let authProvider = AuthProvidingMock()
        authProvider.executeHandler = { _, _, completion in
            completion(.success(.init()))
        }
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: nil
        )
        
        XCTAssertEqual(authProvider.handleCallCount, 0)
        
        UberAuth.login(
            context: context,
            completion: { _ in }
        )
        
        UberAuth.handle(
            URL(string: "https://auth.uber.com/v2")!
        )
        
        XCTAssertEqual(authProvider.handleCallCount, 1)
    }
    
    func test_isLoggedIn_noCurrentContext_returnsFalseIfNoToken() {
        UberAuth.logout()
        XCTAssertFalse(UberAuth.isLoggedIn)
    }
    
    func test_isLoggedIn_callsCurrentContextIsLoggedIn() {
        let authProvider = AuthProvidingMock()
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: nil
        )
        
        UberAuth.login(
            context: context,
            completion: { _ in }
        )
        
        XCTAssertFalse(UberAuth.isLoggedIn)
        
        authProvider.isLoggedIn = true
        
        XCTAssertTrue(UberAuth.isLoggedIn)
    }
    
    func test_logout_triggersAuthProviderLogout() {
        let tokenManager = TokenManagingMock()
        let auth = UberAuth(tokenManager: tokenManager)
        let authProvider = AuthProvidingMock()
        
        let context = AuthContext(
            authDestination: .inApp,
            authProvider: authProvider,
            prefill: nil
        )
        
        auth.login(
            context: context,
            completion: { _ in }
        )
        
        XCTAssertNotNil(auth.currentContext)
        XCTAssertEqual(authProvider.logoutCallCount, 0)
        
        auth.logout()
        
        XCTAssertEqual(authProvider.logoutCallCount, 1)
    }
    
    func test_logout_noCurrentContext_deletesToken() {
        let tokenManager = TokenManagingMock()
        let auth = UberAuth(tokenManager: tokenManager)
        
        XCTAssertEqual(tokenManager.deleteTokenCallCount, 0)
        
        auth.logout()
        
        XCTAssertEqual(tokenManager.deleteTokenCallCount, 1)
    }
}
