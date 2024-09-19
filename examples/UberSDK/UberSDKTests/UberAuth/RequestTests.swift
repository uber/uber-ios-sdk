//
//  RequestTests.swift
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
import XCTest

final class RequestTests: XCTestCase {

    func test_invalidBaseUrl_returnsNil() {
        XCTAssertNil(
            TestRequest().url(baseUrl: "http://auth.uber.com:-80/")
        )
    }
    
    func test_validUrlWithHost() {
        let request = TestRequest(
            contentType: "content-type",
            host: "auth.uber.com",
            method: .get,
            parameters: [
                "key": "value"
            ], 
            path: "/test-path",
            scheme: "https"
        )
        
        XCTAssertEqual(
            request.url(baseUrl: "auth.uber.com")!.absoluteString,
            "https://auth.uber.com/test-path?key=value"
        )
    }
    
    func test_validUrlWithoutHost() {
        let request = TestRequest(
            contentType: "content-type",
            method: .get,
            parameters: [
                "key": "value"
            ],
            path: "/test-path"
        )
        
        XCTAssertEqual(
            request.url(baseUrl: "https://auth.uber.com")!.absoluteString,
            "https://auth.uber.com/test-path?key=value"
        )
    }
    
    func test_urlRequest_containsCustomAndDefaultHeaders() {
        let request = TestRequest(
            contentType: "test_content_type",
            headers: [
                "header_key": "header_value"
            ]
        )
        
        let urlRequest = request.urlRequest(baseUrl: "auth.uber.com")
        let headers = urlRequest!.allHTTPHeaderFields!
        
        XCTAssertEqual(
            headers["header_key"]!,
            "header_value"
        )
        
        XCTAssertEqual(
            headers["Accept-Encoding"]!,
            "gzip, deflate"
        )
        
        XCTAssertEqual(
            headers["Content-Type"]!,
            "test_content_type"
        )
    }
    
    func test_urlRequest_containsBody() {
        
        let body = [
            "body_key": "body_value"
        ]
        
        let request = TestRequest(body: body)
        let urlRequest = request.urlRequest(baseUrl: "auth.uber.com")

        XCTAssertNotNil(urlRequest?.httpBody)
    }
    
    fileprivate struct TestRequest: NetworkRequest {
        var body: [String: String]? = nil
        var contentType: String? = nil
        var headers: [String: String]? = nil
        var host: String? = nil
        var method: HTTPMethod = .get
        var parameters: [String: String]? = nil
        var path: String = ""
        var scheme: String? = nil
        
        struct Response: Codable {}
    }
}
