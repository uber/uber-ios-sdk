//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


@testable import UberAuth
import XCTest

final class AuthorizationCodeAuthProviderTests: XCTestCase {

    func test_executeInAppLogin_createsAuthenticationSession() {
        
        let provider = AuthorizationCodeAuthProvider()
                
        XCTAssertNil(provider.currentSession)
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { _ in }
        )
        
        XCTAssertNotNil(provider.currentSession)
    }
    
    func test_executeInAppLogin_existingSessionBlocksRequest() {
        
        let provider = AuthorizationCodeAuthProvider()
        
        let authSession = AuthenticationSessioningMock()
        provider.currentSession = authSession
        
        XCTAssertEqual(authSession.startCallCount, 0)
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { _ in }
        )
        
        XCTAssertEqual(authSession.startCallCount, 0)
    }

    func test_execute_existingSession_returnsExistingAuthSessionError() {
        let provider = AuthorizationCodeAuthProvider()
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { _ in }
        )
        
        let expectation = XCTestExpectation()
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { result in
                switch result {
                case .failure(.existingAuthSession):
                    expectation.fulfill()
                default:
                    XCTFail()
                }
            }
        )
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_invalidRedirectURI_returnsInvalidRequestError() {
        
        let configurationProvider = ConfigurationProvidingMock(
            clientID: "",
            redirectURI: "uber"
        )
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider
        )
        
        let expectation = XCTestExpectation()
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { result in
                switch result {
                case .failure(.invalidRequest):
                    expectation.fulfill()
                default:
                    XCTFail()
                }
            }
        )
        
        wait(for: [expectation], timeout: 0.1)
    }
}
