//
//  AuthorizeRequestTests.swift
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


@testable import UberAuth
import UberCore
import XCTest

final class AuthorizeRequestTests: XCTestCase {

    func test_generatedUrl() {
        
        let prompt: Prompt = [.consent, .login]
        let promptString = prompt.stringValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        
        let request = AuthorizeRequest(
            app: nil,
            clientID: "test_client_id",
            codeChallenge: "code_challenge",
            prompt: prompt,
            redirectURI: "redirect_uri",
            requestURI: "request_url"
        )
        
        let urlRequest = request.urlRequest(baseUrl: "https://auth.uber.com")!
        let url = urlRequest.url!
        
        XCTAssertEqual(url.host(), "auth.uber.com")
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.path(), "/oauth/v2/universal/authorize")
        XCTAssertTrue(url.query()!.contains("response_type=code"))
        XCTAssertTrue(url.query()!.contains("client_id=test_client_id"))
        XCTAssertTrue(url.query()!.contains("code_challenge=code_challenge"))
        XCTAssertTrue(url.query()!.contains("request_uri=request_url"))
        XCTAssertTrue(url.query()!.contains("code_challenge_method=S256"))
        XCTAssertTrue(url.query()!.contains("redirect_uri=redirect_uri"))
        XCTAssertTrue(url.query()!.contains("prompt=\(promptString)"))
    }
    
    func test_appSpecific_generatedUrls() {
            
        UberApp.allCases.forEach { app in
            let request = AuthorizeRequest(
                app: app,
                clientID: "test_client_id",
                codeChallenge: "code_challenge",
                redirectURI: "redirect_uri",
                requestURI: "request_url"
            )
            
            let urlRequest = request.urlRequest(baseUrl: "https://auth.uber.com")!
            let url = urlRequest.url!
            
            XCTAssertEqual(url.host(), "auth.uber.com")
            XCTAssertEqual(url.scheme, "https")
            XCTAssertEqual(url.path(), "/oauth/v2/\(app.urlIdentifier)/authorize")
            XCTAssertTrue(url.query()!.contains("response_type=code"))
            XCTAssertTrue(url.query()!.contains("client_id=test_client_id"))
            XCTAssertTrue(url.query()!.contains("code_challenge=code_challenge"))
            XCTAssertTrue(url.query()!.contains("request_uri=request_url"))
            XCTAssertTrue(url.query()!.contains("code_challenge_method=S256"))
            XCTAssertTrue(url.query()!.contains("redirect_uri=redirect_uri"))
        }
    }

}
