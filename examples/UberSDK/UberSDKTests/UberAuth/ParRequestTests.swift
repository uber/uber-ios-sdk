//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


@testable import UberAuth
import XCTest

final class ParRequestTests: XCTestCase {

    func test_generatedUrl() {
        
        let prefillValues =  [
            "firstName": "test_first_name",
            "lastName": "test_last_name",
            "phone": "test_phone_number",
            "email": "test_email",
        ]
        
        let request = ParRequest(
            clientID: "test_client_id",
            prefill: prefillValues
        )
        
        let loginHintString = (try! JSONSerialization.data(withJSONObject: prefillValues)).base64EncodedString()
        
        let urlRequest = request.urlRequest(baseUrl: "https://auth.uber.com")!
        let url = urlRequest.url!
        
        XCTAssertEqual(url.host(), "auth.uber.com")
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.path(), "/oauth/v2/par")
        XCTAssertEqual(request.body?["login_hint"], loginHintString)
    }
    
}
