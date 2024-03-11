//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
