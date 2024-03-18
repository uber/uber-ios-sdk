//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
    
    fileprivate struct TestRequest: Request {
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
