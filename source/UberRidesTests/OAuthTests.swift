//
//  OAuthTests.swift
//  UberRidesTests
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
@testable import UberRides

class OAuthTests: XCTestCase {
    var testExpectation: XCTestExpectation!
    var accessToken: AccessToken?
    var error: NSError?
    let timeout: TimeInterval = 2
    let tokenString = "accessToken1234"
    private var redirectURI: String = ""
    
    override func setUp() {
        super.setUp()
        Configuration.bundle = Bundle(for: type(of: self))
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        redirectURI = Configuration.shared.getCallbackURIString()
    }
    
    override func tearDown() {
        _ = TokenManager.deleteToken()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Test for parsing successful access token retrieval.
     */
    func testParseAccessTokenFromRedirect() {
        testExpectation = expectation(description: "success access token")
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        loginBehavior.loginCompletion = loginCompletion()
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        
        let url = URL(string: "\(redirectURI)#access_token=\(tokenString)")
        loginView.webView.load(URLRequest(url: url!))
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            
            XCTAssertNotNil(self.accessToken)
            XCTAssertEqual(self.accessToken!.tokenString, self.tokenString)
        })
    }
    
    /**
     Test for empty access token string (this should never happen though).
     */
    func testParseEmptyAccessTokenFromRedirect() {
        testExpectation = expectation(description: "empty access token")
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        loginBehavior.loginCompletion = loginCompletion()
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        
        let url = URL(string: "\(redirectURI)#access_token=")
        loginView.webView.load(URLRequest(url: url!))
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.accessToken)
            XCTAssertEqual(self.accessToken!.tokenString, "")
        })
    }
    
    /**
     Test error mapping when redirect URI doesn't match what's expected for client ID.
     */
    func testMismatchingRedirectError() {
        testExpectation = expectation(description: "errors")
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        loginBehavior.loginCompletion = loginCompletion()
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        
        let url = URL(string: "\(redirectURI)/errors?error=mismatching_redirect_uri")
        loginView.webView.load(URLRequest(url: url!))
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.mismatchingRedirect.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when redirect URI is invalid.
     */
    func testInvalidRedirectError() {
        testExpectation = expectation(description: "errors")
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        loginBehavior.loginCompletion = loginCompletion()
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        
        let url = URL(string: "\(redirectURI)/errors?error=invalid_redirect_uri")
        loginView.webView.load(URLRequest(url: url!))
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.invalidRedirect.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when client ID is invalid.
     */
    func testInvalidClientIDError() {
        testExpectation = expectation(description: "errors")
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        loginBehavior.loginCompletion = loginCompletion()
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        
        let url = URL(string: "\(redirectURI)/errors?error=invalid_client_id")
        loginView.webView.load(URLRequest(url: url!))
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.invalidClientID.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when scope provided is invalid.
     */
    func testInvalidScopeError() {
        testExpectation = expectation(description: "errors")
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        loginBehavior.loginCompletion = loginCompletion()
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        
        let url = URL(string: "\(redirectURI)/errors?error=invalid_scope")
        loginView.webView.load(URLRequest(url: url!))
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.invalidScope.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when parameters are generally invalid.
     */
    func testInvalidParametersError() {
        testExpectation = expectation(description: "errors")
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        loginBehavior.loginCompletion = loginCompletion()
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        
        let url = URL(string: "\(redirectURI)/errors?error=invalid_parameters")
        loginView.webView.load(URLRequest(url: url!))
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.invalidRequest.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    /**
     Test error mapping when server error is encountered.
     */
    func testServerError() {
        testExpectation = expectation(description: "errors")
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        loginBehavior.loginCompletion = loginCompletion()
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        
        let url = URL(string: "\(redirectURI)/errors?error=server_error")
        loginView.webView.load(URLRequest(url: url!))
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RidesAuthenticationErrorType.serverError.rawValue)
            XCTAssertEqual(self.error?.domain, RidesAuthenticationErrorFactory.errorDomain)
        })
    }
    
    func testBuildinigWithString() {
        let tokenString = "accessTokenString"
        let token = AccessToken(tokenString: tokenString)
        XCTAssertEqual(token.tokenString, tokenString)
    }
    
    /**
     Test saving and object in keychain and retrieving it.
     */
    func testSaveRetrieveObjectFromKeychain() {
        guard let token = tokenFixture() else {
            XCTAssert(false)
            return
        }
        
        let keychain = KeychainWrapper()
        let key = "AccessTokenKey"
        XCTAssertTrue(keychain.setObject(token, key: key))
        
        let result = keychain.getObjectForKey(key) as! AccessToken
        XCTAssertEqual(result.tokenString, token.tokenString)
        XCTAssertEqual(result.refreshToken, token.refreshToken)
        XCTAssertEqual(result.grantedScopes, token.grantedScopes)
        
        XCTAssertTrue(keychain.deleteObjectForKey(key))
        
        // Make sure object was actually deleted
        XCTAssertNil(keychain.getObjectForKey(key))
    }
    
    /**
     Test saving a duplicate key with different value and verify that value is updated.
     */
    func testSaveDuplicateObjectInKeychain() {
        guard let token = tokenFixture(), let newToken = tokenFixture("newTokenString") else {
            XCTAssert(false)
            return
        }
        
        let keychain = KeychainWrapper()
        let key = "AccessTokenKey"
        XCTAssertTrue(keychain.setObject(token, key: key))
        
        XCTAssertTrue(keychain.setObject(newToken, key: key))
        
        let result = keychain.getObjectForKey(key) as! AccessToken
        XCTAssertEqual(result.tokenString, newToken.tokenString)
        XCTAssertEqual(result.refreshToken, newToken.refreshToken)
        XCTAssertEqual(result.grantedScopes, newToken.grantedScopes)
        
        XCTAssertTrue(keychain.deleteObjectForKey(key))
        
        // Make sure object was actually deleted
        XCTAssertNil(keychain.getObjectForKey(key))
    }
    
    /**
     Test that endpoint has correct query
     */
    func testImplicitGrantAuthenticator_withScopes_returnsCorrectEndpoint() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let scopes = [RidesScope.Profile]
        let expectedPath = "/oauth/v2/authorize"
        let implicitGrantBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: scopes)
        
        var params = [String: String]()
        let queryItems: [URLQueryItem] = implicitGrantBehavior.endpoint.query
        
        for query in queryItems {
            params[query.name] = query.value!
        }
        
        XCTAssertEqual(implicitGrantBehavior.endpoint.path, expectedPath)
        XCTAssertEqual(params["scope"], "profile")
        XCTAssertEqual(params["client_id"], "testClientID")
        XCTAssertEqual(params["redirect_uri"], "testURI://uberConnectImplicit")
    }
    
    func testImplicitGrantRedirect_shouldReturnFalse_forNonRedirectUrlRequest() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let request = URLRequest(url: URL(string: "test://notRedirect")!)
        let implicitGrantBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        implicitGrantBehavior.loginCompletion = { accessToken, error in
            XCTAssert(false)
        }
        let result = implicitGrantBehavior.handleRedirect(for: request)
        XCTAssertFalse(result)
    }
    
    func testAuthorizationCodeGrantRedirect_shouldReturnFalse_forNonRedirectUrlRequest() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .authorizationCode)
        let request = URLRequest(url: URL(string: "test://notRedirect")!)
        let authorizationCodeGrantAuthenticator = AuthorizationCodeGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile], state: "state")
        authorizationCodeGrantAuthenticator.loginCompletion = { accessToken, error in
            XCTAssert(false)
        }
        let result = authorizationCodeGrantAuthenticator.handleRedirect(for: request)
        XCTAssertFalse(result)
    }
    
    func testImplicitGrantRedirect_shouldReturnTrue_forCorrectRedirectRequest() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let tokenString = "accessToken1234"
        guard let url = URL(string: "\(redirectURI)#access_token=\(tokenString)") else {
            XCTFail()
            return
        }
        let request = URLRequest(url: url)
        testExpectation = expectation(description: "call login completion")
        let implicitGrantBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        implicitGrantBehavior.loginCompletion = { accessToken, error in
            XCTAssertNil(error)
            XCTAssertNotNil(accessToken)
            XCTAssertEqual(accessToken?.tokenString, tokenString)
            self.testExpectation.fulfill()
        }
        let result = implicitGrantBehavior.handleRedirect(for: request)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testAuthorizationCodeGrantRedirect_shouldReturnTrue_forCorrectRedirectRequest() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .authorizationCode)
        let request = URLRequest(url: URL(string: redirectURI)!)
        let loginCompletionExpectation = expectation(description: "call login completion")
        let executeLoginExpectation = expectation(description: "execute login")
        let authorizationCodeGrantAuthenticator = AuthorizationCodeGrantAuthenticatorMock(presentingViewController: UIViewController(), scopes: [.Profile], state: "state", expectation: executeLoginExpectation)
        authorizationCodeGrantAuthenticator.loginCompletion = { accessToken, error in
            XCTAssertNil(error)
            XCTAssertNil(accessToken)
            loginCompletionExpectation.fulfill()
        }
        let result = authorizationCodeGrantAuthenticator.handleRedirect(for: request)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testAuthorizationCodeGrantRedirect_shouldReturnTrue_forCorrectRedirectRequest_withErrorParameter() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .authorizationCode)
        guard var urlComponents = URLComponents(string: redirectURI) else {
            XCTFail()
            return
        }
        let errorQueryItem = URLQueryItem(name: "error", value: "server_error")
        urlComponents.queryItems = [errorQueryItem]
        guard let requestURL = urlComponents.url else {
            XCTFail()
            return
        }
        let request = URLRequest(url: requestURL)
        let loginCompletionExpectation = expectation(description: "call login completion")
        let authorizationCodeGrantAuthenticator = AuthorizationCodeGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        authorizationCodeGrantAuthenticator.loginCompletion = { accessToken, error in
            if let error = error {
                XCTAssertEqual(RidesAuthenticationErrorType.serverError.rawValue, error.code)
            } else {
                XCTFail()
            }
            XCTAssertNil(accessToken)
            loginCompletionExpectation.fulfill()
        }
        let result = authorizationCodeGrantAuthenticator.handleRedirect(for: request)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testImplicitGrantRedirect_shouldReturnError_forEmptyAccessToken() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        let request = URLRequest(url: URL(string: "\(redirectURI)?error=mismatching_redirect_uri")!)
        testExpectation = expectation(description: "call login completion with error")
        let implicitGrantBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewController(), scopes: [.Profile])
        implicitGrantBehavior.loginCompletion = { accessToken, error in
            XCTAssertNil(accessToken)
            guard let error = error else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(error.domain, "com.uber.rides-ios-sdk.ridesAuthenticationError")
            XCTAssertEqual(error.code, RidesAuthenticationErrorType.mismatchingRedirect.rawValue)
            
            self.testExpectation.fulfill()
        }
        let result = implicitGrantBehavior.handleRedirect(for: request)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testImplicitGrantLogin_showsLogin() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .implicit)
        testExpectation = expectation(description: "present login")
    
        let implicitGrantBehavior = ImplicitGrantAuthenticator(presentingViewController: UIViewControllerMock(expectation: testExpectation), scopes: [.Profile])
        implicitGrantBehavior.login()
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testAuthorizationCodeGrantLogin_showsLogin() {
        redirectURI = Configuration.shared.getCallbackURIString(for: .authorizationCode)
        testExpectation = expectation(description: "present login")
        
        let implicitGrantBehavior = AuthorizationCodeGrantAuthenticator(presentingViewController: UIViewControllerMock(expectation: testExpectation), scopes: [.Profile], state: "state")
        implicitGrantBehavior.login()
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func loginCompletion() -> ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) {
        return { token, error in
            self.accessToken = token
            self.error = error
            self.testExpectation.fulfill()
        }
    }
}

// Mark: Helper

private class AuthorizationCodeGrantAuthenticatorMock: AuthorizationCodeGrantAuthenticator {
    var testExpectation: XCTestExpectation
    
    init(presentingViewController: UIViewController, scopes: [RidesScope], state: String, expectation: XCTestExpectation) {
        self.testExpectation = expectation
        super.init(presentingViewController: presentingViewController, scopes: scopes, state: state)
    }
    
    override func executeRedirect(_ request: URLRequest) {
        self.testExpectation.fulfill()
    }
}

private class UIViewControllerMock : UIViewController {
    var testExpectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.testExpectation = expectation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        self.testExpectation.fulfill()
        return
    }
}

func tokenFixture(_ accessToken: String = "token") -> AccessToken?
{
    var jsonDictionary = [String: String]()
    jsonDictionary["access_token"] = accessToken
    jsonDictionary["refresh_token"] = "refresh"
    jsonDictionary["expires_in"] = "10030.23"
    jsonDictionary["scope"] = "profile history"
    let jsonData = try! JSONEncoder().encode(jsonDictionary)
    return try? JSONDecoder.uberDecoder.decode(AccessToken.self, from: jsonData)
}
