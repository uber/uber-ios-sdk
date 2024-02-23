//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import XCTest
import UberCore
@testable import UberAuth

final class AuthManagerTests: XCTestCase {

    let authManager = AuthManager()
    
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
        
        authManager.login(
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
        
        authManager.login(
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
        
        authManager.login(
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
        
        authManager.login(
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
        
        authManager.login(
            context: context,
            completion: { _ in }
        )
                
        let handled = authManager.handle(url)
        
        XCTAssertTrue(handled)
        XCTAssertEqual(authProvider.handleCallCount, 1)
        XCTAssertEqual(authProvider.executeCallCount, 1)
    }
}
