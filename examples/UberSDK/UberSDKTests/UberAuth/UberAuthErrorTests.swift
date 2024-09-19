//
//  UberAuthErrorTests.swift
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


import AuthenticationServices
import XCTest
@testable import UberAuth

final class UberAuthErrorTests: XCTestCase {

    func test_asWebAuthenticationSessionError() {
        let cancelledError = UberAuthError(error: ASWebAuthenticationSessionError(.canceledLogin))
        XCTAssertEqual(cancelledError, UberAuthError.cancelled)
    }
    
    func test_initWithError_returnsOtherError() {
        let someError = NSError(domain: "domain", code: 2)
        let otherError = UberAuthError(error: someError)
        XCTAssertEqual(otherError, UberAuthError.other(someError))
    }
    
    func test_initWithErrorCode_returnsURLError() {
        let error = UberAuthError(httpStatusCode: URLError.Code.badURL.rawValue)
        XCTAssertEqual(
            error,
            UberAuthError.other(URLError(URLError.Code.badURL))
        )
    }

    func test_initHttpResponse_returnsNilForSuccess() {
        
        let response = HTTPURLResponse(
            url: URL(string: "https://uber.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let error = UberAuthError(response)
        
        XCTAssertNil(error)
    }
    
    func test_initHttpResponse_missingErrorReturnsInvalidRequest() {
        
        let response = HTTPURLResponse(
            url: URL(string: "https://uber.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let error = UberAuthError(response)
        
        XCTAssertEqual(error, UberAuthError.oAuth(.invalidRequest))
    }
    
    func test_initHttpResponse_unsupportedErrorReturnsInvalidRequest() {
        
        let response = HTTPURLResponse(
            url: URL(string: "https://uber.com?error=unsupported_error")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let error = UberAuthError(response)
        
        XCTAssertEqual(error, UberAuthError.oAuth(.invalidRequest))
    }
    
    func test_initHttpResponse_errorMapsToOAuthError() {
        
        let response = HTTPURLResponse(
            url: URL(string: "https://uber.com?error=server_error")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let error = UberAuthError(response)
        
        XCTAssertEqual(error, UberAuthError.oAuth(.serverError))
    }
}
