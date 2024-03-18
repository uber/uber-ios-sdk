//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


@testable import UberAuth
import XCTest

final class AuthorizeRequestTests: XCTestCase {

    func test_generatedUrl() {
        
        let request = AuthorizeRequest(
            type: .url,
            clientID: "test_client_id",
            codeChallenge: "code_challenge",
            redirectURI: "redirect_uri",
            requestURI: "request_url"
        )
        
        let urlRequest = request.urlRequest(baseUrl: "https://auth.uber.com")!
        let url = urlRequest.url!
        
        XCTAssertEqual(url.host(), "auth.uber.com")
        XCTAssertEqual(url.scheme, "https")
        XCTAssertTrue(url.query()!.contains("response_type=code"))
        XCTAssertTrue(url.query()!.contains("client_id=test_client_id"))
        XCTAssertTrue(url.query()!.contains("code_challenge=code_challenge"))
        XCTAssertTrue(url.query()!.contains("request_uri=request_url"))
        XCTAssertTrue(url.query()!.contains("code_challenge_method=S256"))
        XCTAssertTrue(url.query()!.contains("redirect_uri=redirect_uri"))
    }
    
    func test_generatedUrl_deeplink() {
        
        let request = AuthorizeRequest(
            type: .deeplink,
            clientID: "test_client_id",
            codeChallenge: "code_challenge",
            redirectURI: "redirect_uri",
            requestURI: "request_url"
        )
        
        let urlRequest = request.urlRequest(baseUrl: "uber://")!
        let url = urlRequest.url!
        
        XCTAssertEqual(url.host(), "authorize")
        XCTAssertEqual(url.scheme, "uber")
        XCTAssertTrue(url.query()!.contains("response_type=code"))
        XCTAssertTrue(url.query()!.contains("client_id=test_client_id"))
        XCTAssertTrue(url.query()!.contains("code_challenge=code_challenge"))
        XCTAssertTrue(url.query()!.contains("request_uri=request_url"))
        XCTAssertTrue(url.query()!.contains("code_challenge_method=S256"))
        XCTAssertTrue(url.query()!.contains("redirect_uri=redirect_uri"))
    }

}
